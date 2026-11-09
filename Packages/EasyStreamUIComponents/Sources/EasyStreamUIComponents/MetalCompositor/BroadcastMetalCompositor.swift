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
/// - `CVDisplayLink` / `CADisplayLink` notices vsync off the menu run loop
/// - A draw is queued only when a new picture or sprite motion is waiting, and never stacked
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

    private struct SpriteUniforms {
        var viewport: SIMD2<Float> = .zero
        var center: SIMD2<Float> = .zero
        var size: SIMD2<Float> = .zero
        var angle: Float = 0
        var uvOffsetX: Float = 0
        var offsetX: Float = 0
        var opacity: Float = 1
        var scale: Float = 1
        var offsetY: Float = 0
        var uvScaleX: Float = 1
    }

    private struct PlateUniforms {
        var viewport: SIMD2<Float> = .zero
        var uvOrigin: SIMD2<Float> = .zero
        var uvRight: SIMD2<Float> = SIMD2(1, 0)
        var uvDown: SIMD2<Float> = SIMD2(0, 1)
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
    private var spritePipelineState: MTLRenderPipelineState?
    private var platePipelineState: MTLRenderPipelineState?
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
    private let presentLock = NSLock()
    private var presentQueued = false
    private var lastPresentedGeneration: UInt64 = 0
    private var lastPresentedSpriteGeneration: UInt64 = 0
    private var lastPresentedPlateGeneration: UInt64 = 0
    private var lastMotionPresentTime: CFTimeInterval = 0
    private var isCompositorSuspended = false
    private var hasPresentedVideoFrame = false
    private var textureFlushCounter = 0
    private var spriteGeneration: UInt64 = .max
    private var gpuSprites: [(texture: MTLTexture, bitmap: BroadcastMetalSpriteBus.Bitmap)] = []
    private var plateTexture: MTLTexture?
    private var uploadedPlateGeneration: UInt64 = 0

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
        // Keep this short. A one-second age pins a second of camera buffers and the decoder stalls.
        let cacheAttributes = [kCVMetalTextureCacheMaximumTextureAgeKey: 0.05] as CFDictionary
        CVMetalTextureCacheCreate(kCFAllocatorDefault, cacheAttributes, device, nil, &cache)
        textureCache = cache

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)

        buildPipeline()
        buildSpritePipeline()
        buildPlatePipeline()

        displayLinkDriver.onFrame = { [weak self] in
            self?.displayLinkTick()
        }
        BroadcastProgramPlateBus.shared.addListener { [weak self] in
            self?.setCompositorSuspended(false)
            self?.requestDraw()
        }
        BroadcastMetalSpriteBus.shared.addListener { [weak self] in
            // Wake the vsync clock. An immediate draw() here stalls the camera for seconds.
            self?.setCompositorSuspended(false)
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
        ProgramFrameDisplayBus.shared.onProgramMonitorPresetChanged = { [weak self] in
            Task { @MainActor in
                self?.resetProgramLetterboxStabilization()
            }
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

    /// Runs on the display-link thread. Touches AppKit only after a new picture is waiting.
    private func displayLinkTick() {
        let suspended: Bool = {
            stateLock.lock()
            defer { stateLock.unlock() }
            return isCompositorSuspended
        }()
        guard !suspended else { return }

        let now = CACurrentMediaTime()
        let timepieceChanged = BroadcastMetalSpriteBus.shared.refreshTimepieces()
        let generation = ProgramFrameDisplayBus.shared.currentDisplayGeneration()
        let plate = BroadcastProgramPlateBus.shared.status()
        let spriteGeneration = BroadcastMetalSpriteBus.shared.currentGeneration()
        presentLock.lock()
        let generationChanged = generation != lastPresentedGeneration
        let plateChanged = plate.generation != lastPresentedPlateGeneration
        let spriteChanged = spriteGeneration != lastPresentedSpriteGeneration
        let graphicsMoving = BroadcastMetalSpriteBus.shared.presentsMotion() || plate.animating
        let motionDue = !generationChanged
            && now - lastMotionPresentTime >= (1.0 / 30.0)
            && graphicsMoving
        if (!generationChanged && !motionDue && !timepieceChanged && !plateChanged && !spriteChanged) || presentQueued {
            presentLock.unlock()
            return
        }
        presentQueued = true
        presentLock.unlock()

        let present: () -> Void = { [weak self] in
            self?.presentLatestPicture()
        }
        if Thread.isMainThread {
            present()
        } else {
            DispatchQueue.main.async(execute: present)
        }
    }

    private func presentLatestPicture() {
        let generationAtStart = ProgramFrameDisplayBus.shared.currentDisplayGeneration()
        if let view = mtkView {
            performDraw(on: view)
        }
        presentLock.lock()
        lastPresentedGeneration = generationAtStart
        lastPresentedPlateGeneration = BroadcastProgramPlateBus.shared.status().generation
        lastPresentedSpriteGeneration = BroadcastMetalSpriteBus.shared.currentGeneration()
        if BroadcastMetalSpriteBus.shared.presentsMotion() || BroadcastProgramPlateBus.shared.status().animating {
            lastMotionPresentTime = CACurrentMediaTime()
        }
        presentQueued = false
        presentLock.unlock()
    }

    private func requestDraw() {
        DispatchQueue.main.async {
            guard let view = self.mtkView else { return }
            self.performDraw(on: view)
            self.presentLock.lock()
            self.lastPresentedGeneration = ProgramFrameDisplayBus.shared.currentDisplayGeneration()
            self.lastPresentedPlateGeneration = BroadcastProgramPlateBus.shared.status().generation
            self.lastPresentedSpriteGeneration = BroadcastMetalSpriteBus.shared.currentGeneration()
            self.presentLock.unlock()
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
        let plateVisible = BroadcastProgramPlateBus.shared.status().hasFrame
        let spritesVisible = !BroadcastMetalSpriteBus.shared.current().bitmaps.isEmpty
        setCompositorSuspended(!(plateVisible || spritesVisible))
        if plateVisible || spritesVisible {
            requestDraw()
        }
    }

    func clearTransitionVideoFrames() {
        ProgramFrameDisplayBus.shared.clearTransitionLanes()
    }

    func clearProgramVideoFrame() {
        ProgramFrameDisplayBus.shared.clearOnAirLane()
        resetProgramLetterboxStabilization()
    }

    func resetProgramLetterboxStabilization() {
        contentSizeLock.lock()
        lockedProgramContentSize = .zero
        programContentSizeLockFramesRemaining = 0
        contentSizeLock.unlock()
        requestDraw()
    }

    func promoteIncomingFrameToProgram(allowPreviewTier: Bool = false) {
        ProgramBusTrace.event("compositor promoteIncomingFrameToProgram previewTier=\(allowPreviewTier)")
        ProgramFrameDisplayBus.shared.promoteIncomingToOnAir(allowPreviewTier: allowPreviewTier)
        if let sample = ProgramFrameDisplayBus.shared.displaySample(for: .programOnAir) {
            if ProgramFrameQualityGate.meetsConfiguredProgramPreset(
                width: Int(sample.contentSize.x),
                height: Int(sample.contentSize.y)
            ) {
                lockProgramContentSizeFromProgramFrame(forFrames: 240)
            } else if allowPreviewTier {
                lockProgramContentSizeFromProgramFrame(forFrames: 12)
            }
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

    private func buildSpritePipeline() {
        guard let library = Self.loadMetalLibrary(device: device),
              let vertex = library.makeFunction(name: "broadcastSpriteVertex"),
              let fragment = library.makeFunction(name: "broadcastSpriteFragment") else {
            return
        }
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertex
        descriptor.fragmentFunction = fragment
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        spritePipelineState = try? device.makeRenderPipelineState(descriptor: descriptor)
    }

    private func buildPlatePipeline() {
        guard let library = Self.loadMetalLibrary(device: device),
              let vertex = library.makeFunction(name: "broadcastPlateVertex"),
              let fragment = library.makeFunction(name: "broadcastPlateFragment") else {
            return
        }
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertex
        descriptor.fragmentFunction = fragment
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        platePipelineState = try? device.makeRenderPipelineState(descriptor: descriptor)
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

        let transition = resolvedTransition()
        var binding = makeVideoTextureBinding(cache: textureCache, transition: transition)

        overlaySnapshotLock.lock()
        let overlayTexture = overlaySnapshot
        overlaySnapshotLock.unlock()

        let hasOverlay = overlayTexture != nil
        logCompositorDraw(binding: binding)
        let sprites = gpuSpritesForDraw()
        let hasVideo = binding.hasOutgoingVideo || binding.hasIncomingVideo
        let hasPlate = BroadcastProgramPlateBus.shared.status().hasFrame

        guard hasVideo || !sprites.isEmpty || hasPlate else {
            binding.releaseAfterGPU()
            return
        }

        passDescriptor.colorAttachments[0].loadAction = hasPresentedVideoFrame ? .load : .clear
        if !hasPresentedVideoFrame {
            passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        }

        let viewportSize = view.drawableSize
        if !hasVideo {
            passDescriptor.colorAttachments[0].loadAction = .clear
            passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            binding.releaseAfterGPU()
            return
        }

        if hasVideo {
            var textures = TextureSet(
                outgoingBGRA: binding.outgoingBGRA,
                outgoingY: binding.outgoingY,
                outgoingCbCr: binding.outgoingCbCr,
                incomingBGRA: binding.incomingBGRA,
                incomingY: binding.incomingY,
                incomingCbCr: binding.incomingCbCr,
                overlayBGRA: overlayTexture
            )
            var uniforms = makeUniforms(
                viewportSize: viewportSize,
                textures: textures,
                binding: binding,
                transition: transition
            )
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
        }

        let plateRetain = drawProgramPlate(encoder: encoder, viewport: viewportSize, cache: textureCache)
        drawSprites(sprites, encoder: encoder, viewport: viewportSize)
        encoder.endEncoding()

        commandBuffer.addCompletedHandler { [binding, plateRetain] _ in
            binding.releaseAfterGPU()
            withExtendedLifetime(plateRetain) {}
            withExtendedLifetime(sprites) {}
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
        // Flushing every frame stalls the camera. A short age still drops textures that the GPU has finished.
        textureFlushCounter += 1
        if textureFlushCounter >= 12 {
            textureFlushCounter = 0
            CVMetalTextureCacheFlush(textureCache, 0)
        }

        if binding.hasOutgoingVideo {
            hasPresentedVideoFrame = true
        }
    }

    private func drawProgramPlate(
        encoder: MTLRenderCommandEncoder,
        viewport: CGSize,
        cache: CVMetalTextureCache
    ) -> (CVPixelBuffer, CVMetalTexture)? {
        if let sample = BroadcastProgramPlateBus.shared.currentVideoSample() {
            plateTexture = nil
            return drawVideoPlate(sample: sample, encoder: encoder, viewport: viewport, cache: cache)
        }
        guard let spritePipelineState, let samplerState else { return nil }
        let status = BroadcastProgramPlateBus.shared.status()
        guard status.hasFrame else {
            plateTexture = nil
            uploadedPlateGeneration = status.generation
            return nil
        }
        if let update = BroadcastProgramPlateBus.shared.frame(ifGenerationDiffersFrom: uploadedPlateGeneration) {
            plateTexture = makeRawTexture(rgba: update.frame.rgba, width: update.frame.width, height: update.frame.height)
            uploadedPlateGeneration = update.generation
        }
        guard let plateTexture else { return nil }
        let plate = BroadcastMetalSpriteBus.Bitmap(
            rgba: Data(),
            width: plateTexture.width,
            height: plateTexture.height,
            centerX: 0.5,
            centerY: 0.5,
            widthFraction: 1,
            heightFraction: 1,
            uniformSquare: false,
            spinDuration: 0,
            pauseDuration: 0,
            scrollUVPerSecond: 0
        )
        var uniforms = spriteUniforms(for: plate, viewport: SIMD2(Float(viewport.width), Float(viewport.height)), time: CACurrentMediaTime())
        guard uniforms.opacity >= 0.004 else { return nil }
        encoder.setRenderPipelineState(spritePipelineState)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<SpriteUniforms>.stride, index: 0)
        encoder.setFragmentTexture(plateTexture, index: 0)
        encoder.setFragmentSamplerState(samplerState, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        return nil
    }

    private func drawVideoPlate(
        sample: BroadcastProgramPlateBus.VideoSample,
        encoder: MTLRenderCommandEncoder,
        viewport: CGSize,
        cache: CVMetalTextureCache
    ) -> (CVPixelBuffer, CVMetalTexture)? {
        guard let platePipelineState, let samplerState else { return nil }
        guard let bound = makePlateBGRA(from: sample.pixelBuffer, cache: cache) else { return nil }
        var uniforms = plateUniforms(for: sample, viewport: viewport)
        encoder.setRenderPipelineState(platePipelineState)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<PlateUniforms>.stride, index: 0)
        encoder.setFragmentTexture(bound.texture, index: 0)
        encoder.setFragmentSamplerState(samplerState, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        return (sample.pixelBuffer, bound.cvTexture)
    }

    private func makePlateBGRA(
        from pixelBuffer: CVPixelBuffer,
        cache: CVMetalTextureCache
    ) -> (texture: MTLTexture, cvTexture: CVMetalTexture)? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        guard width > 1, height > 1 else { return nil }
        var cvTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            cache,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            width,
            height,
            0,
            &cvTexture
        )
        guard status == kCVReturnSuccess,
              let cvTexture,
              let texture = CVMetalTextureGetTexture(cvTexture) else {
            return nil
        }
        return (texture, cvTexture)
    }

    /// Maps the encoded buffer through its display transform and aspect-fills the viewport.
    /// Texture (0, 0) is the top-left of the buffer, matching the camera picture.
    private func plateUniforms(
        for sample: BroadcastProgramPlateBus.VideoSample,
        viewport: CGSize
    ) -> PlateUniforms {
        let width = CGFloat(CVPixelBufferGetWidth(sample.pixelBuffer))
        let height = CGFloat(CVPixelBufferGetHeight(sample.pixelBuffer))
        var uniforms = PlateUniforms(
            viewport: SIMD2(Float(viewport.width), Float(viewport.height))
        )
        guard width > 1, height > 1, viewport.width > 1, viewport.height > 1 else { return uniforms }

        let transform = sample.displayTransform
        let determinant = transform.a * transform.d - transform.b * transform.c
        let inverse = abs(determinant) > 0.0001 ? transform.inverted() : .identity
        let mapped = [
            CGPoint.zero,
            CGPoint(x: width, y: 0),
            CGPoint(x: 0, y: height),
            CGPoint(x: width, y: height)
        ].map { $0.applying(transform) }
        let minX = mapped.map(\.x).min() ?? 0
        let maxX = mapped.map(\.x).max() ?? width
        let minY = mapped.map(\.y).min() ?? 0
        let maxY = mapped.map(\.y).max() ?? height
        let displayWidth = max(maxX - minX, 1)
        let displayHeight = max(maxY - minY, 1)

        var topLeft = CGPoint(x: minX, y: minY)
        var topRight = CGPoint(x: maxX, y: minY)
        var bottomLeft = CGPoint(x: minX, y: maxY)
        let viewAspect = viewport.width / viewport.height
        let videoAspect = displayWidth / displayHeight
        if videoAspect > viewAspect {
            let visibleWidth = displayHeight * viewAspect
            let inset = (displayWidth - visibleWidth) / 2
            topLeft.x += inset
            topRight.x = topLeft.x + visibleWidth
            bottomLeft.x += inset
        } else if videoAspect < viewAspect {
            let visibleHeight = displayWidth / viewAspect
            let inset = (displayHeight - visibleHeight) / 2
            topLeft.y += inset
            topRight.y += inset
            bottomLeft.y = topLeft.y + visibleHeight
        }

        func textureUV(_ point: CGPoint) -> SIMD2<Float> {
            let pixel = point.applying(inverse)
            return SIMD2(Float(pixel.x / width), Float(pixel.y / height))
        }

        let origin = textureUV(topLeft)
        uniforms.uvOrigin = origin
        uniforms.uvRight = textureUV(topRight) - origin
        uniforms.uvDown = textureUV(bottomLeft) - origin
        return uniforms
    }

    private func makeRawTexture(rgba: Data, width: Int, height: Int) -> MTLTexture? {
        guard width > 0, height > 0, rgba.count >= width * height * 4 else { return nil }
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        descriptor.usage = [.shaderRead]
        guard let texture = device.makeTexture(descriptor: descriptor) else { return nil }
        rgba.withUnsafeBytes { raw in
            guard let base = raw.baseAddress else { return }
            texture.replace(
                region: MTLRegionMake2D(0, 0, width, height),
                mipmapLevel: 0,
                withBytes: base,
                bytesPerRow: width * 4
            )
        }
        return texture
    }

    private func drawSprites(
        _ sprites: [(texture: MTLTexture, bitmap: BroadcastMetalSpriteBus.Bitmap)],
        encoder: MTLRenderCommandEncoder,
        viewport: CGSize
    ) {
        guard !sprites.isEmpty, let spritePipelineState, let samplerState else { return }

        encoder.setRenderPipelineState(spritePipelineState)
        let time = CACurrentMediaTime()
        let viewportPixels = SIMD2(Float(viewport.width), Float(viewport.height))
        for sprite in sprites {
            var uniforms = spriteUniforms(for: sprite.bitmap, viewport: viewportPixels, time: time)
            if uniforms.opacity < 0.004 { continue }
            encoder.setVertexBytes(&uniforms, length: MemoryLayout<SpriteUniforms>.stride, index: 0)
            encoder.setFragmentTexture(sprite.texture, index: 0)
            encoder.setFragmentSamplerState(samplerState, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
    }

    private func gpuSpritesForDraw() -> [(texture: MTLTexture, bitmap: BroadcastMetalSpriteBus.Bitmap)] {
        // Copy the lyric bitmap only when it actually changes. Doing it on every camera frame stalls the picture.
        guard let snapshot = BroadcastMetalSpriteBus.shared.copyBitmapsIfGenerationChanged(from: spriteGeneration) else {
            return gpuSprites
        }
        spriteGeneration = snapshot.generation
        gpuSprites = snapshot.bitmaps.compactMap { bitmap in
            guard let texture = makeSpriteTexture(bitmap) else { return nil }
            return (texture, bitmap)
        }
        return gpuSprites
    }

    private func makeSpriteTexture(_ bitmap: BroadcastMetalSpriteBus.Bitmap) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: bitmap.width,
            height: bitmap.height,
            mipmapped: false
        )
        descriptor.usage = [.shaderRead]
        guard let texture = device.makeTexture(descriptor: descriptor) else { return nil }
        bitmap.rgba.withUnsafeBytes { raw in
            guard let base = raw.baseAddress else { return }
            texture.replace(
                region: MTLRegionMake2D(0, 0, bitmap.width, bitmap.height),
                mipmapLevel: 0,
                withBytes: base,
                bytesPerRow: bitmap.width * 4
            )
        }
        return texture
    }

    private func spriteUniforms(
        for bitmap: BroadcastMetalSpriteBus.Bitmap,
        viewport: SIMD2<Float>,
        time: CFTimeInterval
    ) -> SpriteUniforms {
        var width = bitmap.widthFraction * viewport.x
        var height = bitmap.heightFraction * viewport.y
        if bitmap.uniformSquare {
            let side = min(width, height)
            let aspect = Float(bitmap.width) / Float(max(bitmap.height, 1))
            if aspect >= 1 {
                width = side
                height = side / aspect
            } else {
                height = side
                width = side * aspect
            }
        }
        let motion = sequenceMotion(for: bitmap, time: time, pieceWidth: width, pieceHeight: height)
        let crawl = crawlWindow(for: bitmap, viewportWidth: width, viewportHeight: height, time: time)
        return SpriteUniforms(
            viewport: viewport,
            center: SIMD2(bitmap.centerX * viewport.x, bitmap.centerY * viewport.y),
            size: SIMD2(width, height),
            angle: rotationAngle(time: time, spin: bitmap.spinDuration, pause: bitmap.pauseDuration),
            uvOffsetX: crawl.offset,
            offsetX: motion.offsetX,
            opacity: motion.opacity,
            scale: motion.scale,
            offsetY: motion.offsetY,
            uvScaleX: crawl.scale
        )
    }

    /// A news crawl shows a 1:1 slice of a long strip. `scrollUVPerSecond` is points per second.
    private func crawlWindow(
        for bitmap: BroadcastMetalSpriteBus.Bitmap,
        viewportWidth: Float,
        viewportHeight: Float,
        time: CFTimeInterval
    ) -> (offset: Float, scale: Float) {
        guard bitmap.matchesTextScale, bitmap.width > 0, viewportHeight > 1 else {
            let offset = bitmap.scrollUVPerSecond > 0
                ? Float((time * Double(bitmap.scrollUVPerSecond)).truncatingRemainder(dividingBy: 1))
                : 0
            return (offset, 1)
        }
        let texel = max(viewportHeight / Float(bitmap.height), 0.001)
        let scale = Float(bitmap.height) * viewportWidth / (viewportHeight * Float(bitmap.width))
        let texelsPerSecond = Double(bitmap.scrollUVPerSecond) / Double(texel)
        let fraction = (time * texelsPerSecond / Double(bitmap.width)).truncatingRemainder(dividingBy: 1)
        return (Float(fraction), scale)
    }

    private func sequenceMotion(
        for bitmap: BroadcastMetalSpriteBus.Bitmap,
        time: CFTimeInterval,
        pieceWidth: Float,
        pieceHeight: Float
    ) -> (offsetX: Float, offsetY: Float, opacity: Float, scale: Float) {
        guard bitmap.playsSequence else { return (0, 0, 1, 1) }
        let cue = LowerThirdCue(
            enterDelay: Double(bitmap.enterDelay),
            enterDuration: Double(bitmap.enterDuration),
            exitDelay: Double(bitmap.exitDelay),
            exitDuration: Double(bitmap.exitDuration),
            slideFraction: Double(bitmap.slideFraction),
            enterScale: Double(bitmap.enterScale)
        )
        let sample = cue.sample(elapsed: time - bitmap.sequenceStart)
        let shift = Float(sample.offsetFraction)
        if bitmap.slidesVertically {
            return (0, shift * pieceHeight, Float(sample.opacity), Float(sample.scale))
        }
        return (
            shift * pieceWidth,
            0,
            Float(sample.opacity),
            Float(sample.scale)
        )
    }

    private func rotationAngle(time: CFTimeInterval, spin: Float, pause: Float) -> Float {
        guard spin > 0 else { return 0 }
        let cycle = Double(spin + pause)
        let phase = time.truncatingRemainder(dividingBy: cycle)
        if phase < Double(spin) {
            return Float((phase / Double(spin)) * 2 * Double.pi)
        }
        return 0
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

    private struct ResolvedTransition {
        var isActive: Bool
        var frame: ProgramTransitionFrame
    }

    private func resolvedTransition() -> ResolvedTransition {
        stateLock.lock()
        let transitioning = isTransitioning
        let frame = transitionFrame
        stateLock.unlock()
        return ResolvedTransition(isActive: transitioning, frame: frame)
    }

    private func makeVideoTextureBinding(
        cache: CVMetalTextureCache,
        transition: ResolvedTransition
    ) -> BroadcastMetalTextureBinding {
        let transitioning = transition.isActive
        stateLock.lock()
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
        binding: BroadcastMetalTextureBinding,
        transition: ResolvedTransition
    ) -> Uniforms {
        let transitioning = transition.isActive
        let frame = transition.frame

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
