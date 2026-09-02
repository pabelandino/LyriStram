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
            fullScreenIsLive: fullScreenIsLive
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
            fullScreenIsLive: fullScreenIsLive
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
            container.compositor.setOverlayProvider(overlayProvider)
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
            fullScreenIsLive: Bool
        ) {
            guard let container else { return }

            overlayProvider.widgetLayers = widgetLayers
            overlayProvider.fullScreenResource = fullScreenResource
            overlayProvider.fullScreenFileURL = fullScreenFileURL
            overlayProvider.fullScreenIsLive = fullScreenIsLive
            container.compositor.setOverlayProvider(overlayProvider)
            container.compositor.refreshOverlaySnapshot()

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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCrossfadePresentationMode(idleProgram: Bool, transitioning: Bool, warmingTake: Bool) {
        compositor.setIdleUsesProgramOnly(idleProgram && !transitioning && !warmingTake)
    }

    func enterIdleProgramMode(preservingProgramPresentation: Bool, warmingTake: Bool) {
        _ = preservingProgramPresentation
        compositor.setIdleUsesProgramOnly(!warmingTake)
    }

    func applyCrossfadeSlots(
        programSlot: ProgramTransitionSlot,
        takeSlot: ProgramTransitionSlot,
        incomingOnProgram: Bool
    ) {
        compositor.setTransitionState(
            isTransitioning: true,
            frame: ProgramTransitionFrame(
                outgoing: programSlot,
                incoming: takeSlot,
                lifecycle: .cut,
                presentationMode: programSlot.usesSpatialPresentation || takeSlot.usesSpatialPresentation
                    ? .spatial
                    : .opacityOnly
            )
        )
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
            fullScreenIsLive: fullScreenIsLive
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
            fullScreenIsLive: fullScreenIsLive
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
            container.compositor.setOverlayProvider(overlayProvider)
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
            fullScreenIsLive: Bool
        ) {
            guard let container else { return }

            overlayProvider.widgetLayers = widgetLayers
            overlayProvider.fullScreenResource = fullScreenResource
            overlayProvider.fullScreenFileURL = fullScreenFileURL
            overlayProvider.fullScreenIsLive = fullScreenIsLive
            container.compositor.setOverlayProvider(overlayProvider)
            container.compositor.refreshOverlaySnapshot()

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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCrossfadePresentationMode(idleProgram: Bool, transitioning: Bool, warmingTake: Bool) {
        compositor.setIdleUsesProgramOnly(idleProgram && !transitioning && !warmingTake)
    }

    func enterIdleProgramMode(preservingProgramPresentation: Bool, warmingTake: Bool) {
        _ = preservingProgramPresentation
        compositor.setIdleUsesProgramOnly(!warmingTake)
    }

    func applyCrossfadeSlots(
        programSlot: ProgramTransitionSlot,
        takeSlot: ProgramTransitionSlot,
        incomingOnProgram: Bool
    ) {
        compositor.setTransitionState(
            isTransitioning: true,
            frame: ProgramTransitionFrame(
                outgoing: programSlot,
                incoming: takeSlot,
                lifecycle: .cut,
                presentationMode: programSlot.usesSpatialPresentation || takeSlot.usesSpatialPresentation
                    ? .spatial
                    : .opacityOnly
            )
        )
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
}
#endif
