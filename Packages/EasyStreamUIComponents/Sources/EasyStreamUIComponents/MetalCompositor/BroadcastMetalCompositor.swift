import EasyStreamCore
import Metal
import MetalKit
import WebRTC

/// Shared GPU compositor for program video transitions and widget overlay layers.
final class BroadcastMetalCompositor: NSObject, @unchecked Sendable {
    private struct Uniforms {
        var viewportSize: SIMD2<Float> = .zero
        var outgoingContentSize: SIMD2<Float> = .zero
        var incomingContentSize: SIMD2<Float> = .zero
        var outgoingOpacity: Float = 0
        var incomingOpacity: Float = 0
        var incomingReveal: Float = -1
        var outgoingOffsetX: Float = 0
        var incomingOffsetX: Float = 0
        var outgoingScale: Float = 1
        var incomingScale: Float = 1
        var usesSpatial: Int32 = 0
        var outgoingIsNV12: Int32 = 0
        var incomingIsNV12: Int32 = 0
        var hasOutgoing: Int32 = 0
        var hasIncoming: Int32 = 0
        var hasOverlay: Int32 = 0
    }

    private struct TextureSet {
        var outgoingBGRA: MTLTexture?
        var outgoingY: MTLTexture?
        var outgoingCbCr: MTLTexture?
        var incomingBGRA: MTLTexture?
        var incomingY: MTLTexture?
        var incomingCbCr: MTLTexture?
        var overlayBGRA: MTLTexture?
    }

    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var pipelineState: MTLRenderPipelineState?
    private var textureCache: CVMetalTextureCache?
    private var samplerState: MTLSamplerState?

    private var outgoingFrame = BroadcastMetalVideoFrame.LayerFrame()
    private var incomingFrame = BroadcastMetalVideoFrame.LayerFrame()
    private var programFrame = BroadcastMetalVideoFrame.LayerFrame()
    private var lockedProgramContentSize: SIMD2<Float> = .zero
    private var programContentSizeLockFramesRemaining = 0

    private var transitionFrame = ProgramTransitionFrame.cutIncoming
    private var isTransitioning = false
    /// When off-air, render the warmed incoming lane as full program output without attaching preview to program sink.
    private var idleShowsIncomingAsProgram = false

    private let stateLock = NSLock()
    private let frameLock = NSLock()
    private let overlaySnapshotLock = NSLock()
    private weak var mtkView: MTKView?

    private var overlayProvider: BroadcastMetalOverlayProvider?
    private var overlaySnapshot: MTLTexture?
    private var overlayAnimationTimer: Timer?
    private var drawScheduled = false

    let outgoingSink: BroadcastMetalVideoSink
    let incomingSink: BroadcastMetalVideoSink
    let programSink: BroadcastMetalVideoSink

    override init() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let queue = device.makeCommandQueue() else {
            fatalError("Metal is unavailable")
        }
        self.device = device
        self.commandQueue = queue
        self.outgoingSink = BroadcastMetalVideoSink(slot: .outgoing)
        self.incomingSink = BroadcastMetalVideoSink(slot: .incoming)
        self.programSink = BroadcastMetalVideoSink(slot: .program)
        super.init()

        outgoingSink.compositor = self
        incomingSink.compositor = self
        programSink.compositor = self

        var cache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cache)
        textureCache = cache

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)

        buildPipeline()
    }

    var outgoingRenderer: RTCVideoRenderer { outgoingSink }
    var incomingRenderer: RTCVideoRenderer { incomingSink }
    var programRenderer: RTCVideoRenderer { programSink }

    func attach(to view: MTKView) {
        let configure = {
            self.mtkView = view
            view.device = self.device
            view.colorPixelFormat = .bgra8Unorm
            view.framebufferOnly = true
            view.isPaused = true
            view.enableSetNeedsDisplay = false
            view.delegate = self
        }
        if Thread.isMainThread {
            configure()
        } else {
            DispatchQueue.main.async(execute: configure)
        }
    }

    func setTransitionState(isTransitioning: Bool, frame: ProgramTransitionFrame) {
        stateLock.lock()
        self.isTransitioning = isTransitioning
        transitionFrame = frame
        stateLock.unlock()
        requestDraw()
    }

    func setIdleMode(showIncomingAsProgram: Bool) {
        stateLock.lock()
        idleShowsIncomingAsProgram = showIncomingAsProgram
        isTransitioning = false
        transitionFrame = .cutIncoming
        stateLock.unlock()
        requestDraw()
    }

    @MainActor
    func setOverlayProvider(_ provider: BroadcastMetalOverlayProvider?) {
        overlayProvider = provider
        updateOverlayAnimationTimer()
        bakeOverlaySnapshot(for: mtkView?.drawableSize ?? .zero)
        requestDraw()
    }

    func invalidateOverlay() {
        Task { @MainActor in
            bakeOverlaySnapshot(for: mtkView?.drawableSize ?? .zero)
        }
        requestDraw()
    }

    @MainActor
    func refreshOverlaySnapshot() {
        bakeOverlaySnapshot(for: mtkView?.drawableSize ?? .zero)
        requestDraw()
    }

    nonisolated func receive(_ frame: RTCVideoFrame?, slot: BroadcastMetalVideoSink.Slot) {
        guard let frame else { return }
        let layerFrame = BroadcastMetalVideoFrame.layerFrame(from: frame)
        frameLock.lock()
        switch slot {
        case .outgoing: outgoingFrame = layerFrame
        case .incoming: incomingFrame = layerFrame
        case .program:
            programFrame = layerFrame
        }
        frameLock.unlock()
        requestDraw()
    }

    private func requestDraw() {
        DispatchQueue.main.async {
            guard let view = self.mtkView else { return }
            if view.drawableSize.width > 1, view.drawableSize.height > 1 {
                view.draw()
            } else if !self.drawScheduled {
                self.drawScheduled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.drawScheduled = false
                    self.mtkView?.draw()
                }
            }
        }
    }

    func invalidateDisplay() {
        requestDraw()
    }

    func clearMetalVideoFrames() {
        frameLock.lock()
        outgoingFrame = BroadcastMetalVideoFrame.LayerFrame()
        incomingFrame = BroadcastMetalVideoFrame.LayerFrame()
        programFrame = BroadcastMetalVideoFrame.LayerFrame()
        lockedProgramContentSize = .zero
        programContentSizeLockFramesRemaining = 0
        idleShowsIncomingAsProgram = false
        frameLock.unlock()
        requestDraw()
    }

    func clearTransitionVideoFrames() {
        frameLock.lock()
        outgoingFrame = BroadcastMetalVideoFrame.LayerFrame()
        incomingFrame = BroadcastMetalVideoFrame.LayerFrame()
        frameLock.unlock()
        requestDraw()
    }

    func clearProgramVideoFrame() {
        frameLock.lock()
        programFrame = BroadcastMetalVideoFrame.LayerFrame()
        lockedProgramContentSize = .zero
        programContentSizeLockFramesRemaining = 0
        frameLock.unlock()
        requestDraw()
    }

    func promoteIncomingFrameToProgram() {
        frameLock.lock()
        if incomingFrame.pixelBuffer != nil {
            programFrame = incomingFrame
            lockedProgramContentSize = incomingFrame.contentSize
            programContentSizeLockFramesRemaining = 24
        }
        incomingFrame = BroadcastMetalVideoFrame.LayerFrame()
        frameLock.unlock()
        requestDraw()
    }

    /// Copies the current program lane dimensions for letterbox stability after a cut.
    func lockProgramContentSizeFromProgramFrame(forFrames frameCount: Int = 24) {
        frameLock.lock()
        if programFrame.contentSize.x > 1, programFrame.contentSize.y > 1 {
            lockedProgramContentSize = programFrame.contentSize
            programContentSizeLockFramesRemaining = frameCount
        }
        frameLock.unlock()
    }

    @MainActor
    private func updateOverlayAnimationTimer() {
        overlayAnimationTimer?.invalidate()
        overlayAnimationTimer = nil
        guard let provider = overlayProvider, provider.needsContinuousRefresh else { return }

        let interval = provider.overlayRefreshInterval
        overlayAnimationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.bakeOverlaySnapshot(for: self.mtkView?.drawableSize ?? .zero)
                self.requestDraw()
            }
        }
    }

    @MainActor
    private func bakeOverlaySnapshot(for viewportSize: CGSize) {
        let texture: MTLTexture?
        if viewportSize.width > 1,
           viewportSize.height > 1,
           let provider = overlayProvider {
            texture = provider.overlayTexture(for: viewportSize, device: device)
        } else {
            texture = nil
        }

        overlaySnapshotLock.lock()
        overlaySnapshot = texture
        overlaySnapshotLock.unlock()
    }

    private func buildPipeline() {
        guard let library = Self.loadMetalLibrary(device: device),
              let vertex = library.makeFunction(name: "broadcastCompositorVertex"),
              let fragment = library.makeFunction(name: "broadcastCompositorFragment") else {
            return
        }

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertex
        descriptor.fragmentFunction = fragment
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineState = try? device.makeRenderPipelineState(descriptor: descriptor)
    }

    private static func loadMetalLibrary(device: MTLDevice) -> MTLLibrary? {
        #if SWIFT_PACKAGE
        if let library = try? device.makeDefaultLibrary(bundle: Bundle.module) {
            return library
        }
        #endif
        return device.makeDefaultLibrary()
    }

    private func render(in view: MTKView) {
        guard view.drawableSize.width > 1, view.drawableSize.height > 1 else { return }
        guard let pipelineState,
              let drawable = view.currentDrawable,
              let passDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor),
              let samplerState else {
            return
        }

        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)

        let viewportSize = view.drawableSize
        var textures = makeVideoTextures()
        var uniforms = makeUniforms(viewportSize: viewportSize, textures: textures)

        overlaySnapshotLock.lock()
        textures.overlayBGRA = overlaySnapshot
        overlaySnapshotLock.unlock()
        uniforms.hasOverlay = textures.overlayBGRA != nil ? 1 : 0

        encoder.setRenderPipelineState(pipelineState)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 0)
        encoder.setFragmentTexture(textures.outgoingBGRA, index: 0)
        encoder.setFragmentTexture(textures.outgoingY, index: 1)
        encoder.setFragmentTexture(textures.outgoingCbCr, index: 2)
        encoder.setFragmentTexture(textures.incomingBGRA, index: 3)
        encoder.setFragmentTexture(textures.incomingY, index: 4)
        encoder.setFragmentTexture(textures.incomingCbCr, index: 5)
        encoder.setFragmentTexture(textures.overlayBGRA, index: 6)
        encoder.setFragmentSamplerState(samplerState, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func makeUniforms(viewportSize: CGSize, textures: TextureSet) -> Uniforms {
        stateLock.lock()
        let transitioning = isTransitioning
        let frame = transitionFrame
        stateLock.unlock()

        stateLock.lock()
        let showIncomingAsProgram = idleShowsIncomingAsProgram
        stateLock.unlock()

        frameLock.lock()
        let outgoing = transitioning ? outgoingFrame : programFrame
        let incoming = incomingFrame
        frameLock.unlock()

        var uniforms = Uniforms()
        uniforms.viewportSize = SIMD2(Float(viewportSize.width), Float(viewportSize.height))

        if transitioning {
            uniforms.outgoingContentSize = effectiveContentSize(
                frame: outgoing,
                bgra: textures.outgoingBGRA,
                y: textures.outgoingY
            )
            uniforms.incomingContentSize = effectiveContentSize(
                frame: incoming,
                bgra: textures.incomingBGRA,
                y: textures.incomingY
            )
            uniforms.outgoingOpacity = Float(frame.outgoing.opacity)
            uniforms.incomingOpacity = Float(frame.incoming.opacity)
            uniforms.outgoingOffsetX = Float(frame.outgoing.offsetX)
            uniforms.incomingOffsetX = Float(frame.incoming.offsetX)
            uniforms.outgoingScale = Float(frame.outgoing.scale)
            uniforms.incomingScale = Float(frame.incoming.scale)
            uniforms.usesSpatial = frame.usesVisualTransform ? 1 : 0
            uniforms.outgoingIsNV12 = outgoing.isNV12 ? 1 : 0
            uniforms.incomingIsNV12 = incoming.isNV12 ? 1 : 0
            uniforms.hasOutgoing = outgoing.pixelBuffer != nil ? 1 : 0
            uniforms.hasIncoming = incoming.pixelBuffer != nil ? 1 : 0
            if let reveal = frame.incoming.reveal {
                uniforms.incomingReveal = Float(reveal)
            }
        } else if showIncomingAsProgram {
            if incoming.pixelBuffer != nil {
                uniforms.outgoingContentSize = effectiveContentSize(
                    frame: incoming,
                    bgra: textures.incomingBGRA,
                    y: textures.incomingY
                )
                uniforms.outgoingOpacity = 1
                uniforms.outgoingIsNV12 = incoming.isNV12 ? 1 : 0
                uniforms.hasOutgoing = 1
            } else {
                uniforms.outgoingOpacity = 0
                uniforms.hasOutgoing = 0
            }
        } else {
            var programContentSize = effectiveContentSize(
                frame: programFrame,
                bgra: textures.outgoingBGRA,
                y: textures.outgoingY
            )
            frameLock.lock()
            if programContentSizeLockFramesRemaining > 0,
               lockedProgramContentSize.x > 1,
               lockedProgramContentSize.y > 1 {
                programContentSize = lockedProgramContentSize
                programContentSizeLockFramesRemaining -= 1
            }
            frameLock.unlock()
            uniforms.outgoingContentSize = programContentSize
            uniforms.outgoingOpacity = programFrame.pixelBuffer != nil ? 1 : 0
            uniforms.outgoingIsNV12 = programFrame.isNV12 ? 1 : 0
            uniforms.hasOutgoing = programFrame.pixelBuffer != nil ? 1 : 0
        }

        return uniforms
    }

    private func effectiveContentSize(
        frame: BroadcastMetalVideoFrame.LayerFrame,
        bgra: MTLTexture?,
        y: MTLTexture?
    ) -> SIMD2<Float> {
        if let y, y.width > 1, y.height > 1 {
            return SIMD2(Float(y.width), Float(y.height))
        }
        if let bgra, bgra.width > 1, bgra.height > 1 {
            return SIMD2(Float(bgra.width), Float(bgra.height))
        }
        if frame.contentSize.x > 1, frame.contentSize.y > 1 {
            return frame.contentSize
        }
        return frame.contentSize
    }

    private func makeVideoTextures() -> TextureSet {
        stateLock.lock()
        let transitioning = isTransitioning
        let showIncomingAsProgram = idleShowsIncomingAsProgram
        stateLock.unlock()

        frameLock.lock()
        let programBuffer = programFrame.pixelBuffer
        let programNV12 = programFrame.isNV12
        let incomingBuffer = incomingFrame.pixelBuffer
        let incomingNV12 = incomingFrame.isNV12

        let outgoingBuffer: CVPixelBuffer?
        let outgoingNV12: Bool
        if transitioning {
            outgoingBuffer = outgoingFrame.pixelBuffer
            outgoingNV12 = outgoingFrame.isNV12
        } else if showIncomingAsProgram {
            outgoingBuffer = incomingBuffer
            outgoingNV12 = incomingNV12
        } else {
            outgoingBuffer = programBuffer
            outgoingNV12 = programNV12
        }
        frameLock.unlock()

        var set = TextureSet()
        if outgoingNV12 {
            let planes = BroadcastMetalTextureUploader.makeNV12Textures(from: outgoingBuffer, cache: textureCache)
            set.outgoingY = planes.y
            set.outgoingCbCr = planes.cbcr
        } else {
            set.outgoingBGRA = BroadcastMetalTextureUploader.makeBGRATexture(from: outgoingBuffer, cache: textureCache)
        }

        if incomingNV12 {
            let planes = BroadcastMetalTextureUploader.makeNV12Textures(from: incomingBuffer, cache: textureCache)
            set.incomingY = planes.y
            set.incomingCbCr = planes.cbcr
        } else {
            set.incomingBGRA = BroadcastMetalTextureUploader.makeBGRATexture(from: incomingBuffer, cache: textureCache)
        }

        return set
    }
}

extension BroadcastMetalCompositor: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        Task { @MainActor in
            bakeOverlaySnapshot(for: size)
        }
        requestDraw()
    }

    func draw(in view: MTKView) {
        render(in: view)
    }
}
