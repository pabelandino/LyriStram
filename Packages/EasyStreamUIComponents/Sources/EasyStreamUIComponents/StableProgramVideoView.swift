import SwiftUI
import EasyStreamCore
import WebRTC

/// Video layer isolated from widget/preview overlays so UI churn does not detach WebRTC renderers.
public struct StableProgramVideoView: View {
    let programDisplayTrack: RTCVideoTrack?
    let outgoingProgramTrack: RTCVideoTrack?
    let incomingProgramTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let transitionProgress: Double
    let transitionKind: SwitchTransitionKind
    let emptyStatusMessage: String
    let showsEmptyWhenNoGraphics: Bool
    let hasAirGraphics: Bool

    public init(
        programDisplayTrack: RTCVideoTrack?,
        outgoingProgramTrack: RTCVideoTrack?,
        incomingProgramTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        transitionProgress: Double,
        transitionKind: SwitchTransitionKind,
        emptyStatusMessage: String,
        showsEmptyWhenNoGraphics: Bool = true,
        hasAirGraphics: Bool = false
    ) {
        self.programDisplayTrack = programDisplayTrack
        self.outgoingProgramTrack = outgoingProgramTrack
        self.incomingProgramTrack = incomingProgramTrack
        self.isTransitioning = isTransitioning
        self.transitionProgress = transitionProgress
        self.transitionKind = transitionKind
        self.emptyStatusMessage = emptyStatusMessage
        self.showsEmptyWhenNoGraphics = showsEmptyWhenNoGraphics
        self.hasAirGraphics = hasAirGraphics
    }

    public var body: some View {
        Group {
            if let displayTrack = programDisplayTrack {
                TransitionProgramView(
                    programTrack: displayTrack,
                    outgoingTrack: isTransitioning ? outgoingProgramTrack : nil,
                    previewTrack: isTransitioning ? incomingProgramTrack : nil,
                    isTransitioning: isTransitioning,
                    progress: transitionProgress,
                    kind: transitionKind
                )
            } else if showsEmptyWhenNoGraphics, !hasAirGraphics {
                ContentUnavailableView {
                    Label("Sin programa", systemImage: "tv.slash")
                } description: {
                    Text(emptyStatusMessage)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

/// Widget overlay for committed air graphics.
public struct StableWidgetOverlayView: View {
    let layers: [ProgramFeedWidgetLayer]
    let onWidgetLiveAutoDismiss: ((UUID) -> Void)?

    public init(
        layers: [ProgramFeedWidgetLayer],
        onWidgetLiveAutoDismiss: ((UUID) -> Void)? = nil
    ) {
        self.layers = layers
        self.onWidgetLiveAutoDismiss = onWidgetLiveAutoDismiss
    }

    public var body: some View {
        ZStack {
            ForEach(layers) { layer in
                BroadcastWidgetCanvas(
                    configuration: layer.configuration,
                    logoURL: layer.logoURL,
                    isEditing: false,
                    isLive: layer.isLive,
                    allowsMotion: layer.isLive,
                    placement: .constant(layer.configuration.placement),
                    onLiveSequenceEnded: layer.isLive ? { onWidgetLiveAutoDismiss?(layer.id) } : nil
                )
                .id(layer.id)
            }
        }
        .animation(nil, value: layers.map(\.id))
    }
}

/// Preview/draft overlay — allowed to re-render freely without touching the program video bus.
public struct PreviewWidgetOverlayView: View {
    let layers: [ProgramFeedWidgetLayer]
    let isPlacementEditing: Bool
    @Binding var editingPlacement: BroadcastWidgetPlacement

    public init(
        layers: [ProgramFeedWidgetLayer],
        isPlacementEditing: Bool,
        editingPlacement: Binding<BroadcastWidgetPlacement>
    ) {
        self.layers = layers
        self.isPlacementEditing = isPlacementEditing
        self._editingPlacement = editingPlacement
    }

    public var body: some View {
        ZStack {
            ForEach(layers) { layer in
                BroadcastWidgetCanvas(
                    configuration: layer.configuration,
                    logoURL: layer.logoURL,
                    isEditing: isPlacementEditing,
                    isLive: false,
                    allowsMotion: !isPlacementEditing,
                    placement: $editingPlacement
                )
            }
        }
    }
}

/// Full program feed for external outputs: stable video + committed air graphics only.
public struct LiveProgramFeedView: View {
    let programDisplayTrack: RTCVideoTrack?
    let outgoingProgramTrack: RTCVideoTrack?
    let incomingProgramTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let transitionProgress: Double
    let transitionKind: SwitchTransitionKind
    let widgetLayers: [ProgramFeedWidgetLayer]
    let fullScreenResource: BroadcastResource?
    let fullScreenFileURL: URL?
    let fullScreenIsLive: Bool
    let emptyStatusMessage: String
    let isCleanBroadcastOutput: Bool
    let onWidgetLiveAutoDismiss: ((UUID) -> Void)?

    public init(
        programDisplayTrack: RTCVideoTrack?,
        outgoingProgramTrack: RTCVideoTrack?,
        incomingProgramTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        transitionProgress: Double,
        transitionKind: SwitchTransitionKind,
        widgetLayers: [ProgramFeedWidgetLayer],
        fullScreenResource: BroadcastResource?,
        fullScreenFileURL: URL?,
        fullScreenIsLive: Bool,
        emptyStatusMessage: String,
        isCleanBroadcastOutput: Bool = false,
        onWidgetLiveAutoDismiss: ((UUID) -> Void)? = nil
    ) {
        self.programDisplayTrack = programDisplayTrack
        self.outgoingProgramTrack = outgoingProgramTrack
        self.incomingProgramTrack = incomingProgramTrack
        self.isTransitioning = isTransitioning
        self.transitionProgress = transitionProgress
        self.transitionKind = transitionKind
        self.widgetLayers = widgetLayers
        self.fullScreenResource = fullScreenResource
        self.fullScreenFileURL = fullScreenFileURL
        self.fullScreenIsLive = fullScreenIsLive
        self.emptyStatusMessage = emptyStatusMessage
        self.isCleanBroadcastOutput = isCleanBroadcastOutput
        self.onWidgetLiveAutoDismiss = onWidgetLiveAutoDismiss
    }

    public var body: some View {
        ZStack {
            Color.black

            StableProgramVideoView(
                programDisplayTrack: programDisplayTrack,
                outgoingProgramTrack: outgoingProgramTrack,
                incomingProgramTrack: incomingProgramTrack,
                isTransitioning: isTransitioning,
                transitionProgress: transitionProgress,
                transitionKind: transitionKind,
                emptyStatusMessage: emptyStatusMessage,
                showsEmptyWhenNoGraphics: !isCleanBroadcastOutput,
                hasAirGraphics: !widgetLayers.isEmpty || fullScreenResource != nil
            )

            if let fullScreen = fullScreenResource, let fileURL = fullScreenFileURL {
                BroadcastResourceDisplayView(
                    resource: fullScreen,
                    fileURL: fileURL,
                    widgetConfiguration: nil,
                    logoURL: nil,
                    isLive: fullScreenIsLive,
                    isEditingWidget: false,
                    widgetPlacement: .constant(BroadcastWidgetPlacement())
                )
            }

            StableWidgetOverlayView(
                layers: widgetLayers,
                onWidgetLiveAutoDismiss: onWidgetLiveAutoDismiss
            )
        }
    }
}

/// Edge-to-edge clean output for external displays and network-bound program (no UI chrome).
public struct BroadcastCleanProgramFeedView: View {
    let programDisplayTrack: RTCVideoTrack?
    let outgoingProgramTrack: RTCVideoTrack?
    let incomingProgramTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let transitionProgress: Double
    let transitionKind: SwitchTransitionKind
    let widgetLayers: [ProgramFeedWidgetLayer]
    let fullScreenResource: BroadcastResource?
    let fullScreenFileURL: URL?
    let fullScreenIsLive: Bool
    let onWidgetLiveAutoDismiss: ((UUID) -> Void)?

    public init(
        programDisplayTrack: RTCVideoTrack?,
        outgoingProgramTrack: RTCVideoTrack?,
        incomingProgramTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        transitionProgress: Double,
        transitionKind: SwitchTransitionKind,
        widgetLayers: [ProgramFeedWidgetLayer],
        fullScreenResource: BroadcastResource?,
        fullScreenFileURL: URL?,
        fullScreenIsLive: Bool,
        onWidgetLiveAutoDismiss: ((UUID) -> Void)? = nil
    ) {
        self.programDisplayTrack = programDisplayTrack
        self.outgoingProgramTrack = outgoingProgramTrack
        self.incomingProgramTrack = incomingProgramTrack
        self.isTransitioning = isTransitioning
        self.transitionProgress = transitionProgress
        self.transitionKind = transitionKind
        self.widgetLayers = widgetLayers
        self.fullScreenResource = fullScreenResource
        self.fullScreenFileURL = fullScreenFileURL
        self.fullScreenIsLive = fullScreenIsLive
        self.onWidgetLiveAutoDismiss = onWidgetLiveAutoDismiss
    }

    public var body: some View {
        GeometryReader { geometry in
            LiveProgramFeedView(
                programDisplayTrack: programDisplayTrack,
                outgoingProgramTrack: outgoingProgramTrack,
                incomingProgramTrack: incomingProgramTrack,
                isTransitioning: isTransitioning,
                transitionProgress: transitionProgress,
                transitionKind: transitionKind,
                widgetLayers: widgetLayers,
                fullScreenResource: fullScreenResource,
                fullScreenFileURL: fullScreenFileURL,
                fullScreenIsLive: fullScreenIsLive,
                emptyStatusMessage: "",
                isCleanBroadcastOutput: true,
                onWidgetLiveAutoDismiss: onWidgetLiveAutoDismiss
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}
