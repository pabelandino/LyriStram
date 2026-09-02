import SwiftUI
import WebRTC
import EasyStreamCore
import EasyStreamUIComponents

/// Live program monitor — observes only switcher/video + frozen air bus (never widget draft edits).
struct DirectorProgramLiveMonitorView: View {
    let viewModel: DirectorSessionViewModel
    @Bindable var liveProgramAir: LiveProgramAirStore
    var studioPreviewWidgetID: UUID?

    private var directorCommittedAirLayers: [ProgramFeedWidgetLayer] {
        var layers = liveProgramAir.widgetLayers
        if let hiddenID = liveProgramAir.directorEditingWidgetID {
            layers = layers.filter { $0.id != hiddenID }
        }
        if let previewID = studioPreviewWidgetID {
            layers = layers.filter { $0.id != previewID }
        }
        return layers
    }

    var body: some View {
        ZStack {
            DirectorProgramVideoBusView(
                viewModel: viewModel,
                hasAirGraphics: !directorCommittedAirLayers.isEmpty || liveProgramAir.fullScreenResource != nil
            )

            DirectorProgramAirGraphicsView(
                widgetLayers: directorCommittedAirLayers,
                fullScreenResource: liveProgramAir.fullScreenResource,
                fullScreenFileURL: liveProgramAir.fullScreenFileURL,
                fullScreenIsLive: liveProgramAir.fullScreenIsLive,
                onWidgetLiveAutoDismiss: { liveProgramAir.requestWidgetAutoDismiss($0) }
            )
        }
        .animation(nil, value: viewModel.isTransitioning)
        .animation(nil, value: viewModel.transitionProgress)
        .animation(nil, value: liveProgramAir.revision)
    }
}

/// Draft/preview layer — isolated from the live output video bus.
struct DirectorProgramPreviewOverlayView: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel

    var body: some View {
        ZStack {
            if let previewFullScreen = mediaViewModel.previewFullScreenGraphicResource {
                BroadcastResourceDisplayView(
                    resource: previewFullScreen,
                    fileURL: mediaViewModel.fileURL(for: previewFullScreen),
                    widgetConfiguration: nil,
                    logoURL: nil,
                    isLive: false,
                    isEditingWidget: false,
                    widgetPlacement: .constant(BroadcastWidgetPlacement())
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.yellow.opacity(0.85), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                }
            }

            if !mediaViewModel.previewOverlayWidgetLayers.isEmpty {
                PreviewWidgetOverlayView(
                    layers: mediaViewModel.previewOverlayWidgetLayers.map {
                        ProgramFeedWidgetLayer(
                            id: $0.id,
                            configuration: $0.configuration,
                            logoURL: $0.logoURL,
                            isLive: false,
                            isEditing: true
                        )
                    },
                    isPlacementEditing: mediaViewModel.isWidgetPlacementEditing,
                    editingPlacement: $mediaViewModel.draftWidgetConfiguration.placement
                )
            }
        }
    }
}

/// Studio chrome (preview badge, placement hint) — does not wrap the video bus.
struct DirectorProgramStudioHintsOverlay: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if mediaViewModel.isWidgetStudioOpen,
               mediaViewModel.editingWidgetResource.map({
                   !mediaViewModel.liveWidgetIDs.contains($0.id)
               }) ?? true {
                Text("PREVIEW")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.yellow.opacity(0.9), in: Capsule())
                    .foregroundStyle(.black)
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }

            if mediaViewModel.isWidgetStudioOpen, !mediaViewModel.isWidgetPlacementEditing {
                Label("Play", systemImage: "play.fill")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(BroadcastTheme.previewGreen.opacity(0.92), in: Capsule())
                    .foregroundStyle(.black)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }

            if mediaViewModel.isWidgetPlacementEditing {
                Text("Arrastra el centro para mover · puntos en esquinas para redimensionar")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.65), in: Capsule())
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .allowsHitTesting(false)
    }
}

/// Reads only switcher/video state — not widget draft configuration.
private struct DirectorProgramVideoBusView: View, Equatable {
    let programDisplayTrack: RTCVideoTrack?
    let outgoingProgramTrack: RTCVideoTrack?
    let incomingProgramTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let transitionProgress: Double
    let transitionKind: SwitchTransitionKind
    let emptyStatusMessage: String
    let hasAirGraphics: Bool

    init(viewModel: DirectorSessionViewModel, hasAirGraphics: Bool) {
        programDisplayTrack = viewModel.programDisplayTrack
        outgoingProgramTrack = viewModel.outgoingProgramVideoTrack
        incomingProgramTrack = viewModel.isTransitioning
            ? viewModel.transitionIncomingVideoTrack
            : nil
        isTransitioning = viewModel.isTransitioning
        transitionProgress = viewModel.transitionProgress
        transitionKind = viewModel.selectedTransition.kind
        emptyStatusMessage = viewModel.statusMessage
        self.hasAirGraphics = hasAirGraphics
    }

    nonisolated static func == (lhs: DirectorProgramVideoBusView, rhs: DirectorProgramVideoBusView) -> Bool {
        guard lhs.programDisplayTrack === rhs.programDisplayTrack
            && lhs.outgoingProgramTrack === rhs.outgoingProgramTrack
            && lhs.incomingProgramTrack === rhs.incomingProgramTrack
            && lhs.isTransitioning == rhs.isTransitioning
            && lhs.transitionKind == rhs.transitionKind
            && lhs.emptyStatusMessage == rhs.emptyStatusMessage
            && lhs.hasAirGraphics == rhs.hasAirGraphics
        else { return false }

        if lhs.isTransitioning && rhs.isTransitioning {
            if lhs.transitionProgress >= 0.95 || rhs.transitionProgress >= 0.95 {
                return lhs.transitionProgress == rhs.transitionProgress
            }
            return abs(lhs.transitionProgress - rhs.transitionProgress) < 0.02
        }
        return true
    }

    var body: some View {
        StableProgramVideoView(
            programDisplayTrack: programDisplayTrack,
            outgoingProgramTrack: outgoingProgramTrack,
            incomingProgramTrack: incomingProgramTrack,
            isTransitioning: isTransitioning,
            transitionProgress: transitionProgress,
            transitionKind: transitionKind,
            emptyStatusMessage: emptyStatusMessage,
            hasAirGraphics: hasAirGraphics
        )
    }
}

/// Committed on-air graphics (director display may hide the widget currently being edited).
private struct DirectorProgramAirGraphicsView: View {
    let widgetLayers: [ProgramFeedWidgetLayer]
    let fullScreenResource: BroadcastResource?
    let fullScreenFileURL: URL?
    let fullScreenIsLive: Bool
    let onWidgetLiveAutoDismiss: ((UUID) -> Void)?

    var body: some View {
        ZStack {
            if let fullScreen = fullScreenResource,
               let fileURL = fullScreenFileURL {
                BroadcastResourceDisplayView(
                    resource: fullScreen,
                    fileURL: fileURL,
                    widgetConfiguration: nil,
                    logoURL: nil,
                    isLive: fullScreenIsLive,
                    isEditingWidget: false,
                    widgetPlacement: .constant(BroadcastWidgetPlacement())
                )
                .background(Color.black.opacity(0.01))
            }

            StableWidgetOverlayView(
                layers: widgetLayers,
                onWidgetLiveAutoDismiss: onWidgetLiveAutoDismiss
            )
        }
    }
}
