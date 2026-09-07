#if canImport(UIKit)
import SwiftUI
import MetalKit
import EasyStreamCore
import WebRTC

/// Unified Metal program feed: video transitions + widget overlays in one GPU compositor.
struct BroadcastMetalProgramFeedPlatformView: UIViewRepresentable {
    let programTrack: RTCVideoTrack?
    let outgoingTrack: RTCVideoTrack?
    let incomingTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let progress: Double
    let kind: SwitchTransitionKind
    let widgetLayers: [ProgramFeedWidgetLayer]
    let fullScreenResource: BroadcastResource?
    let fullScreenFileURL: URL?
    let fullScreenIsLive: Bool
    let embedsOverlays: Bool
    let onWidgetLiveAutoDismiss: ((UUID) -> Void)?

    func makeUIView(context: Context) -> BroadcastMetalProgramFeedContainerUIView {
        let view = BroadcastMetalProgramFeedContainerUIView()
        context.coordinator.attach(to: view)
        context.coordinator.setAutoDismissHandler(onWidgetLiveAutoDismiss)
        context.coordinator.sync(
            programTrack: programTrack,
            outgoingTrack: outgoingTrack,
            incomingTrack: incomingTrack,
            isTransitioning: isTransitioning,
            progress: progress,
            kind: kind,
            widgetLayers: widgetLayers,
            fullScreenResource: fullScreenResource,
            fullScreenFileURL: fullScreenFileURL,
            fullScreenIsLive: fullScreenIsLive,
            embedsOverlays: embedsOverlays
        )
        return view
    }

    func updateUIView(_ uiView: BroadcastMetalProgramFeedContainerUIView, context: Context) {
        context.coordinator.attach(to: uiView)
        context.coordinator.setAutoDismissHandler(onWidgetLiveAutoDismiss)
        context.coordinator.sync(
            programTrack: programTrack,
            outgoingTrack: outgoingTrack,
            incomingTrack: incomingTrack,
            isTransitioning: isTransitioning,
            progress: progress,
            kind: kind,
            widgetLayers: widgetLayers,
            fullScreenResource: fullScreenResource,
            fullScreenFileURL: fullScreenFileURL,
            fullScreenIsLive: fullScreenIsLive,
            embedsOverlays: embedsOverlays
        )
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: BroadcastMetalProgramFeedContainerUIView,
        context: Context
    ) -> CGSize? {
        ProgramCrossfadeLayout.boundedSize(for: proposal)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    @MainActor
    final class Coordinator {
        private let session = ProgramCrossfadeSession()
        private let overlayProvider = BroadcastMetalSwiftUIOverlayProvider()
        private weak var container: BroadcastMetalProgramFeedContainerUIView?

        func attach(to container: BroadcastMetalProgramFeedContainerUIView) {
            self.container = container
        }

        func sync(
            programTrack: RTCVideoTrack?,
            outgoingTrack: RTCVideoTrack?,
            incomingTrack: RTCVideoTrack?,
            isTransitioning: Bool,
            progress: Double,
            kind: SwitchTransitionKind,
            widgetLayers: [ProgramFeedWidgetLayer],
            fullScreenResource: BroadcastResource?,
            fullScreenFileURL: URL?,
            fullScreenIsLive: Bool,
            embedsOverlays: Bool
        ) {
            guard let container else { return }

            if embedsOverlays {
                overlayProvider.widgetLayers = widgetLayers
                overlayProvider.fullScreenResource = fullScreenResource
                overlayProvider.fullScreenFileURL = fullScreenFileURL
                overlayProvider.fullScreenIsLive = fullScreenIsLive
                container.compositor.setOverlayProvider(overlayProvider)
                container.compositor.refreshOverlaySnapshot()
            } else {
                container.compositor.setOverlayProvider(nil)
            }

            session.apply(
                on: container,
                programTrack: programTrack,
                outgoingTrack: outgoingTrack,
                incomingTrack: incomingTrack,
                isTransitioning: isTransitioning,
                progress: progress,
                kind: kind
            )
        }

        func setAutoDismissHandler(_ handler: ((UUID) -> Void)?) {
            overlayProvider.onWidgetLiveAutoDismiss = handler
        }
    }
}

final class BroadcastMetalProgramFeedContainerUIView: UIView, ProgramCrossfadeHost {
    let compositor = BroadcastMetalCompositor()
    private let compositorView = MTKView(frame: .zero, device: nil)

    var outgoingRenderer: RTCVideoRenderer { compositor.outgoingRenderer }
    var incomingRenderer: RTCVideoRenderer { compositor.incomingRenderer }
    var programRenderer: RTCVideoRenderer { compositor.programRenderer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        clipsToBounds = true
        compositorView.translatesAutoresizingMaskIntoConstraints = false
        compositorView.isUserInteractionEnabled = false
        addSubview(compositorView)
        NSLayoutConstraint.activate([
            compositorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            compositorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            compositorView.topAnchor.constraint(equalTo: topAnchor),
            compositorView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        compositor.attach(to: compositorView)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else { return }
        setNeedsLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }
        let scale = window?.screen.scale ?? traitCollection.displayScale
        compositorView.drawableSize = BroadcastMetalDrawableLimits.cappedDrawableSize(
            bounds: bounds.size,
            scale: scale
        )
        compositor.invalidateDisplay()
    }

    func setCrossfadePresentationMode(idleProgram: Bool, transitioning: Bool, warmingTake: Bool) {
        guard !transitioning else { return }
        compositor.setIdleMode(showIncomingAsProgram: warmingTake)
    }

    func enterIdleProgramMode(preservingProgramPresentation: Bool, warmingTake: Bool) {
        _ = preservingProgramPresentation
        compositor.setIdleMode(showIncomingAsProgram: warmingTake)
    }

    func applyCrossfadeSlots(
        programSlot: ProgramTransitionSlot,
        takeSlot: ProgramTransitionSlot,
        incomingOnProgram: Bool
    ) {
        applyTransitionFrame(
            ProgramTransitionFrame(
                outgoing: programSlot,
                incoming: takeSlot,
                lifecycle: .cut,
                presentationMode: programSlot.usesSpatialPresentation || takeSlot.usesSpatialPresentation
                    ? .spatial
                    : .opacityOnly
            ),
            incomingOnProgram: incomingOnProgram
        )
    }

    func applyTransitionFrame(_ frame: ProgramTransitionFrame, incomingOnProgram: Bool) {
        compositor.setTransitionState(isTransitioning: true, frame: frame)
        _ = incomingOnProgram
    }

    func beginTransitionHandoff() {}

    func completeTransitionHandoff() {
        compositor.setTransitionState(isTransitioning: false, frame: .cutIncoming)
    }

    func revealTakeLayer() {}

    func finalizeTransitionHandoff() {
        completeTransitionHandoff()
    }

    func resetCrossfadePresentation() {
        compositor.setTransitionState(isTransitioning: false, frame: .cutIncoming)
    }

    func resetTransitionSlotPresentation() {}

    func clearMetalVideoFrames() {
        compositor.clearMetalVideoFrames()
    }

    func clearMetalTransitionFrames() {
        compositor.clearTransitionVideoFrames()
    }

    func clearProgramVideoFrame() {
        compositor.clearProgramVideoFrame()
    }

    func promoteIncomingFrameToProgram() {
        compositor.promoteIncomingFrameToProgram()
        compositor.lockProgramContentSizeFromProgramFrame()
    }
}
#endif

#if canImport(AppKit)
import SwiftUI
import MetalKit
import EasyStreamCore
import WebRTC

struct BroadcastMetalProgramFeedPlatformView: NSViewRepresentable {
    let programTrack: RTCVideoTrack?
    let outgoingTrack: RTCVideoTrack?
    let incomingTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let progress: Double
    let kind: SwitchTransitionKind
    let widgetLayers: [ProgramFeedWidgetLayer]
    let fullScreenResource: BroadcastResource?
    let fullScreenFileURL: URL?
    let fullScreenIsLive: Bool
    let embedsOverlays: Bool
    let onWidgetLiveAutoDismiss: ((UUID) -> Void)?

    func makeNSView(context: Context) -> BroadcastMetalProgramFeedContainerNSView {
        let view = BroadcastMetalProgramFeedContainerNSView()
        context.coordinator.attach(to: view)
        context.coordinator.setAutoDismissHandler(onWidgetLiveAutoDismiss)
        context.coordinator.sync(
            programTrack: programTrack,
            outgoingTrack: outgoingTrack,
            incomingTrack: incomingTrack,
            isTransitioning: isTransitioning,
            progress: progress,
            kind: kind,
            widgetLayers: widgetLayers,
            fullScreenResource: fullScreenResource,
            fullScreenFileURL: fullScreenFileURL,
            fullScreenIsLive: fullScreenIsLive,
            embedsOverlays: embedsOverlays
        )
        return view
    }

    func updateNSView(_ nsView: BroadcastMetalProgramFeedContainerNSView, context: Context) {
        context.coordinator.attach(to: nsView)
        context.coordinator.setAutoDismissHandler(onWidgetLiveAutoDismiss)
        context.coordinator.sync(
            programTrack: programTrack,
            outgoingTrack: outgoingTrack,
            incomingTrack: incomingTrack,
            isTransitioning: isTransitioning,
            progress: progress,
            kind: kind,
            widgetLayers: widgetLayers,
            fullScreenResource: fullScreenResource,
            fullScreenFileURL: fullScreenFileURL,
            fullScreenIsLive: fullScreenIsLive,
            embedsOverlays: embedsOverlays
        )
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: BroadcastMetalProgramFeedContainerNSView,
        context: Context
    ) -> CGSize? {
        ProgramCrossfadeLayout.boundedSize(for: proposal)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    @MainActor
    final class Coordinator {
        private let session = ProgramCrossfadeSession()
        private let overlayProvider = BroadcastMetalSwiftUIOverlayProvider()
        private weak var container: BroadcastMetalProgramFeedContainerNSView?

        func attach(to container: BroadcastMetalProgramFeedContainerNSView) {
            self.container = container
        }

        func sync(
            programTrack: RTCVideoTrack?,
            outgoingTrack: RTCVideoTrack?,
            incomingTrack: RTCVideoTrack?,
            isTransitioning: Bool,
            progress: Double,
            kind: SwitchTransitionKind,
            widgetLayers: [ProgramFeedWidgetLayer],
            fullScreenResource: BroadcastResource?,
            fullScreenFileURL: URL?,
            fullScreenIsLive: Bool,
            embedsOverlays: Bool
        ) {
            guard let container else { return }

            if embedsOverlays {
                overlayProvider.widgetLayers = widgetLayers
                overlayProvider.fullScreenResource = fullScreenResource
                overlayProvider.fullScreenFileURL = fullScreenFileURL
                overlayProvider.fullScreenIsLive = fullScreenIsLive
                container.compositor.setOverlayProvider(overlayProvider)
                container.compositor.refreshOverlaySnapshot()
            } else {
                container.compositor.setOverlayProvider(nil)
            }

            session.apply(
                on: container,
                programTrack: programTrack,
                outgoingTrack: outgoingTrack,
                incomingTrack: incomingTrack,
                isTransitioning: isTransitioning,
                progress: progress,
                kind: kind
            )
        }

        func setAutoDismissHandler(_ handler: ((UUID) -> Void)?) {
            overlayProvider.onWidgetLiveAutoDismiss = handler
        }
    }
}

final class BroadcastMetalProgramFeedContainerNSView: NSView, ProgramCrossfadeHost {
    let compositor = BroadcastMetalCompositor()
    private let compositorView = MTKView(frame: .zero, device: nil)

    var outgoingRenderer: RTCVideoRenderer { compositor.outgoingRenderer }
    var incomingRenderer: RTCVideoRenderer { compositor.incomingRenderer }
    var programRenderer: RTCVideoRenderer { compositor.programRenderer }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        clipsToBounds = true
        compositorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(compositorView)
        NSLayoutConstraint.activate([
            compositorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            compositorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            compositorView.topAnchor.constraint(equalTo: topAnchor),
            compositorView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        compositor.attach(to: compositorView)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil else { return }
        needsLayout = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        guard bounds.width > 0, bounds.height > 0 else { return }
        let scale = window?.backingScaleFactor ?? 2
        compositorView.drawableSize = BroadcastMetalDrawableLimits.cappedDrawableSize(
            bounds: bounds.size,
            scale: scale
        )
        compositor.invalidateDisplay()
    }

    func setCrossfadePresentationMode(idleProgram: Bool, transitioning: Bool, warmingTake: Bool) {
        guard !transitioning else { return }
        compositor.setIdleMode(showIncomingAsProgram: warmingTake)
    }

    func enterIdleProgramMode(preservingProgramPresentation: Bool, warmingTake: Bool) {
        _ = preservingProgramPresentation
        compositor.setIdleMode(showIncomingAsProgram: warmingTake)
    }

    func applyCrossfadeSlots(
        programSlot: ProgramTransitionSlot,
        takeSlot: ProgramTransitionSlot,
        incomingOnProgram: Bool
    ) {
        applyTransitionFrame(
            ProgramTransitionFrame(
                outgoing: programSlot,
                incoming: takeSlot,
                lifecycle: .cut,
                presentationMode: programSlot.usesSpatialPresentation || takeSlot.usesSpatialPresentation
                    ? .spatial
                    : .opacityOnly
            ),
            incomingOnProgram: incomingOnProgram
        )
    }

    func applyTransitionFrame(_ frame: ProgramTransitionFrame, incomingOnProgram: Bool) {
        compositor.setTransitionState(isTransitioning: true, frame: frame)
        _ = incomingOnProgram
    }

    func beginTransitionHandoff() {}

    func completeTransitionHandoff() {
        compositor.setTransitionState(isTransitioning: false, frame: .cutIncoming)
    }

    func revealTakeLayer() {}

    func finalizeTransitionHandoff() {
        completeTransitionHandoff()
    }

    func resetCrossfadePresentation() {
        compositor.setTransitionState(isTransitioning: false, frame: .cutIncoming)
    }

    func resetTransitionSlotPresentation() {}

    func clearMetalVideoFrames() {
        compositor.clearMetalVideoFrames()
    }

    func clearMetalTransitionFrames() {
        compositor.clearTransitionVideoFrames()
    }

    func clearProgramVideoFrame() {
        compositor.clearProgramVideoFrame()
    }

    func promoteIncomingFrameToProgram() {
        compositor.promoteIncomingFrameToProgram()
        compositor.lockProgramContentSizeFromProgramFrame()
    }
}
#endif
