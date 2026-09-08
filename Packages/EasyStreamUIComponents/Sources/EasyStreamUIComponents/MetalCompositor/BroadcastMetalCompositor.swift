import CoreVideo
import EasyStreamCore
import Metal
import MetalKit
import QuartzCore
import WebRTC
import EasyStreamVideoPipeline

/// Shared GPU compositor for program video transitions and widget overlay layers.
///
/// Presentation follows Apple's guidance:
/// - `CVDisplayLink` / `CADisplayLink` drives draws on vsync
/// - `CVMetalTexture` + `CVPixelBuffer` retained until `MTLCommandBuffer` completes
/// - Skip draw when compositor is suspended (no program source)
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

    private var lockedProgramContentSize: SIMD2<Float> = .zero
    private var programContentSizeLockFramesRemaining = 0

    private var transitionFrame = ProgramTransitionFrame.cutIncoming
    private var isTransitioning = false
    private var idleShowsIncomingAsProgram = false

    private let stateLock = NSLock()
    private let contentSizeLock = NSLock()
    private let overlaySnapshotLock = NSLock()
    private weak var mtkView: MTKView?

    private var overlayProvider: BroadcastMetalOverlayProvider?
    private var overlaySnapshot: MTLTexture?
    private var overlayAnimationTimer: Timer?
    private var drawScheduled = false
    private var isCompositorSuspended = false
    private var hasPresentedVideoFrame = false

    private let displayLinkDriver = BroadcastMetalDisplayLinkDriver()

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

        var cache: CVMetalTextureCache?
        let cacheAttributes = [kCVMetalTextureCacheMaximumTextureAgeKey: 1.0] as CFDictionary
        CVMetalTextureCacheCreate(kCFAllocatorDefault, cacheAttributes, device, nil, &cache)
        textureCache = cache

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)

        buildPipeline()

        displayLinkDriver.onFrame = { [weak self] in
            self?.displayLinkTick()
        }
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
            view.autoResizeDrawable = false
            view.delegate = self
            self.startDisplayLinkIfNeeded()
        }
        if Thread.isMainThread {
            configure()
        } else {
            DispatchQueue.main.async(execute: configure)
        }
    }

    func detachFromView() {
        DispatchQueue.main.async {
            self.displayLinkDriver.stop()
            self.mtkView = nil
        }
    }

    func setCompositorSuspended(_ suspended: Bool) {
        stateLock.lock()
        isCompositorSuspended = suspended
        stateLock.unlock()
        if suspended {
            DispatchQueue.main.async {
                self.displayLinkDriver.stop()
            }
        } else {
            startDisplayLinkIfNeeded()
        }
    }

    func setTransitionState(isTransitioning: Bool, frame: ProgramTransitionFrame) {
        stateLock.lock()
        self.isTransitioning = isTransitioning
        transitionFrame = frame
        if isTransitioning {
            isCompositorSuspended = false
        }
        stateLock.unlock()
        startDisplayLinkIfNeeded()
    }

    func setIdleMode(showIncomingAsProgram: Bool) {
        stateLock.lock()
        idleShowsIncomingAsProgram = showIncomingAsProgram
        isTransitioning = false
        transitionFrame = .cutIncoming
        stateLock.unlock()
        startDisplayLinkIfNeeded()
    }

    @MainActor
    func setOverlayProvider(_ provider: BroadcastMetalOverlayProvider?) {
        overlayProvider = provider
        updateOverlayAnimationTimer()
        bakeOverlaySnapshot(for: mtkView?.drawableSize ?? .zero)
    }

    func invalidateOverlay() {
        Task { @MainActor in
            bakeOverlaySnapshot(for: mtkView?.drawableSize ?? .zero)
        }
    }

    @MainActor
    func refreshOverlaySnapshot() {
        bakeOverlaySnapshot(for: mtkView?.drawableSize ?? .zero)
    }

    nonisolated func receive(_ frame: RTCVideoFrame?, slot: BroadcastMetalVideoSink.Slot) {
        guard let frame else { return }
        ProgramFrameDisplayBus.shared.enqueue(frame, lane: slot.busSlot)
    }

    private func startDisplayLinkIfNeeded() {
        DispatchQueue.main.async {
            guard self.mtkView != nil else { return }
            let suspended: Bool = {
                self.stateLock.lock()
                defer { self.stateLock.unlock() }
                return self.isCompositorSuspended
            }()
            guard !suspended else { return }
            self.displayLinkDriver.preferredFramesPerSecond = 60
            self.displayLinkDriver.start()
        }
    }

    private func displayLinkTick() {
        guard let view = mtkView else { return }
        let suspended: Bool = {
            stateLock.lock()
            defer { stateLock.unlock() }
            return isCompositorSuspended
        }()
        guard !suspended else { return }
        performDraw(on: view)
    }

    private func requestDraw() {
        DispatchQueue.main.async {
            guard let view = self.mtkView else { return }
            self.performDraw(on: view)
        }
    }

    private func performDraw(on view: MTKView) {
        if view.drawableSize.width > 1, view.drawableSize.height > 1 {
            view.draw()
        } else if !drawScheduled {
            drawScheduled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.drawScheduled = false
                self.mtkView?.draw()
            }
        }
    }

    func invalidateDisplay() {
        requestDraw()
    }

    func clearMetalVideoFrames() {
        ProgramFrameDisplayBus.shared.clearAllLanes()
        contentSizeLock.lock()
        lockedProgramContentSize = .zero
        programContentSizeLockFramesRemaining = 0
        contentSizeLock.unlock()
        stateLock.lock()
        idleShowsIncomingAsProgram = false
        stateLock.unlock()
        hasPresentedVideoFrame = false
        setCompositorSuspended(true)
    }

    func clearTransitionVideoFrames() {
        ProgramFrameDisplayBus.shared.clearTransitionLanes()
    }

    func clearProgramVideoFrame() {
        ProgramFrameDisplayBus.shared.clearOnAirLane()
        contentSizeLock.lock()
        lockedProgramContentSize = .zero
        programContentSizeLockFramesRemaining = 0
        contentSizeLock.unlock()
    }

    func promoteIncomingFrameToProgram() {
        ProgramBusTrace.event("compositor promoteIncomingFrameToProgram")
        ProgramFrameDisplayBus.shared.promoteIncomingToOnAir()
        if let sample = ProgramFrameDisplayBus.shared.displaySample(for: .programOnAir),
           ProgramFrameQualityGate.acceptsOnAirFrame(
               width: Int(sample.contentSize.x),
               height: Int(sample.contentSize.y)
           ) {
            lockProgramContentSizeFromProgramFrame(forFrames: 240)
        }
        setCompositorSuspended(false)
        requestDraw()
    }

    func lockProgramContentSizeFromProgramFrame(forFrames frameCount: Int = 24) {
        guard let sample = ProgramFrameDisplayBus.shared.displaySample(for: .programOnAir) else { return }
        contentSizeLock.lock()
        if sample.contentSize.x > 1, sample.contentSize.y > 1 {
            lockedProgramContentSize = sample.contentSize
            programContentSizeLockFramesRemaining = frameCount
        }
        contentSizeLock.unlock()
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
              let samplerState,
              let textureCache else {
            return
        }

        var binding = makeVideoTextureBinding(cache: textureCache)

        overlaySnapshotLock.lock()
        let overlayTexture = overlaySnapshot
        overlaySnapshotLock.unlock()

        let hasOverlay = overlayTexture != nil
        logCompositorDraw(binding: binding)

        guard binding.hasOutgoingVideo || binding.hasIncomingVideo else {
            binding.releaseAfterGPU()
            return
        }

        passDescriptor.colorAttachments[0].loadAction = hasPresentedVideoFrame ? .load : .clear
        if !hasPresentedVideoFrame {
            passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        }

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            binding.releaseAfterGPU()
            return
        }

        let viewportSize = view.drawableSize
        var textures = TextureSet(
            outgoingBGRA: binding.outgoingBGRA,
            outgoingY: binding.outgoingY,
            outgoingCbCr: binding.outgoingCbCr,
            incomingBGRA: binding.incomingBGRA,
            incomingY: binding.incomingY,
            incomingCbCr: binding.incomingCbCr,
            overlayBGRA: overlayTexture
        )
        var uniforms = makeUniforms(viewportSize: viewportSize, textures: textures, binding: binding)
        uniforms.hasOverlay = hasOverlay ? 1 : 0

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

        commandBuffer.addCompletedHandler { [binding] _ in
            binding.releaseAfterGPU()
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()

        if binding.hasOutgoingVideo {
            hasPresentedVideoFrame = true
        }
    }

    private func layerFrame(for lane: ProgramFrameBusSlot) -> BroadcastMetalVideoFrame.LayerFrame {
        guard let sample = ProgramFrameDisplayBus.shared.displaySample(for: lane) else {
            return BroadcastMetalVideoFrame.LayerFrame()
        }
        return BroadcastMetalVideoFrame.LayerFrame(
            pixelBuffer: sample.pixelBuffer,
            contentSize: sample.contentSize,
            isNV12: sample.isNV12
        )
    }

    private func makeVideoTextureBinding(cache: CVMetalTextureCache) -> BroadcastMetalTextureBinding {
        stateLock.lock()
        let transitioning = isTransitioning
        let showIncomingAsProgram = idleShowsIncomingAsProgram
        stateLock.unlock()

        let programFrame = layerFrame(for: .programOnAir)
        let incomingFrame = layerFrame(for: .programIncoming)
        let outgoingFrame = layerFrame(for: .programOutgoing)

        let binding = BroadcastMetalTextureBinding()

        if transitioning {
            binding.bindOutgoing(
                from: outgoingFrame.pixelBuffer,
                isNV12: outgoingFrame.isNV12,
                cache: cache
            )
            binding.bindIncoming(
                from: incomingFrame.pixelBuffer,
                isNV12: incomingFrame.isNV12,
                cache: cache
            )
        } else if showIncomingAsProgram {
            binding.bindOutgoing(
                from: incomingFrame.pixelBuffer,
                isNV12: incomingFrame.isNV12,
                cache: cache
            )
        } else {
            binding.bindOutgoing(
                from: programFrame.pixelBuffer,
                isNV12: programFrame.isNV12,
                cache: cache
            )
        }

        return binding
    }

    private func makeUniforms(
        viewportSize: CGSize,
        textures: TextureSet,
        binding: BroadcastMetalTextureBinding
    ) -> Uniforms {
        stateLock.lock()
        let transitioning = isTransitioning
        let frame = transitionFrame
        stateLock.unlock()

        stateLock.lock()
        let showIncomingAsProgram = idleShowsIncomingAsProgram
        stateLock.unlock()

        let programFrame = layerFrame(for: .programOnAir)
        let incomingFrame = layerFrame(for: .programIncoming)
        let outgoingFrame = layerFrame(for: .programOutgoing)
        let outgoing = transitioning ? outgoingFrame : programFrame
        let incoming = incomingFrame

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
            uniforms.hasOutgoing = binding.hasOutgoingVideo ? 1 : 0
            uniforms.hasIncoming = binding.hasIncomingVideo ? 1 : 0
            if let reveal = frame.incoming.reveal {
                uniforms.incomingReveal = Float(reveal)
            }
        } else if showIncomingAsProgram {
            if binding.hasOutgoingVideo {
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
            contentSizeLock.lock()
            if programContentSizeLockFramesRemaining > 0,
               lockedProgramContentSize.x > 1,
               lockedProgramContentSize.y > 1 {
                programContentSize = lockedProgramContentSize
                programContentSizeLockFramesRemaining -= 1
            }
            contentSizeLock.unlock()
            uniforms.outgoingContentSize = programContentSize
            uniforms.outgoingOpacity = binding.hasOutgoingVideo ? 1 : 0
            uniforms.outgoingIsNV12 = programFrame.isNV12 ? 1 : 0
            uniforms.hasOutgoing = binding.hasOutgoingVideo ? 1 : 0
        }

        return uniforms
    }

    private func logCompositorDraw(binding: BroadcastMetalTextureBinding) {
        stateLock.lock()
        let transitioning = isTransitioning
        let showIncomingAsProgram = idleShowsIncomingAsProgram
        stateLock.unlock()

        guard binding.hasOutgoingVideo else {
            ProgramBusTrace.eventThrottled(
                "compositor-miss",
                intervalMs: 300,
                "compositor draw miss outgoing transitioning=\(transitioning) incomingAsProgram=\(showIncomingAsProgram)"
            )
            return
        }

        let width = Int(binding.outgoingY?.width ?? binding.outgoingBGRA?.width ?? 0)
        let height = Int(binding.outgoingY?.height ?? binding.outgoingBGRA?.height ?? 0)
        guard width > 0, height > 0 else { return }
        ProgramBusTrace.compositorPresent(
            width: width,
            height: height,
            transitioning: transitioning
        )
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
}

extension BroadcastMetalCompositor: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        Task { @MainActor in
            bakeOverlaySnapshot(for: size)
        }
    }

    func draw(in view: MTKView) {
        render(in: view)
    }
}
