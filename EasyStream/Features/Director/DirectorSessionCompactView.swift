import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// iPhone compact director layout — List-based fallback when workspace columns do not fit.
struct DirectorSessionCompactView: View {
    @Bindable var viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    @Bindable var liveProgramAir: LiveProgramAirStore
    let onOpenSettings: () -> Void

    var body: some View {
        List {
            Section {
                Label(viewModel.statusMessage, systemImage: "antenna.radiowaves.left.and.right")
            }

            Section("Programa") {
                DirectorProgramLiveMonitorView(viewModel: viewModel, liveProgramAir: liveProgramAir)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .listRowInsets(EdgeInsets())
            }

            Section("Preview") {
                ForEach(viewModel.sources) { source in
                    CameraSourceTile(
                        name: source.displayName,
                        track: DirectorPreviewTileTrackPolicy.liveTileTrack(
                            for: source.id,
                            track: source.videoTrack,
                            previewSourceID: viewModel.previewSourceID,
                            programSourceID: viewModel.programSourceID
                        ),
                        hasVideoSignal: source.videoTrack != nil,
                        connectionState: source.connectionState,
                        isPreview: source.id == viewModel.previewSourceID,
                        isProgram: source.id == viewModel.programSourceID,
                        onSelect: { viewModel.selectPreview(source.id) }
                    )
                    .listRowInsets(EdgeInsets())
                }
            }

            Section("Transición") {
                SwitchTransitionControls(transition: $viewModel.selectedTransition)
            }

            Section {
                TakeToProgramButton(isEnabled: canTake && !viewModel.isTransitioning) {
                    viewModel.takeToProgram()
                }
            }

            DirectorSessionCompactDestinationSections(viewModel: viewModel)

            Section("Biblioteca") {
                DirectorLibraryRailView(mediaViewModel: mediaViewModel)
                    .listRowInsets(EdgeInsets())
            }

            Section {
                Button(action: onOpenSettings) {
                    Label("Ajustes del director", systemImage: "gearshape")
                }
            }

            Section("En red") {
                ForEach(viewModel.devices) { device in
                    DiscoveredDeviceRow(device: device)
                }
            }
        }
#if os(macOS)
        .listStyle(.inset)
#endif
    }

    private var canTake: Bool {
        guard let preview = viewModel.previewSourceID else { return false }
        if let program = viewModel.programSourceID, preview == program { return false }
        return viewModel.connectionState(for: preview) == .connected
    }
}

struct DirectorSessionCompactDestinationSections: View {
    @Bindable var viewModel: DirectorSessionViewModel

    var body: some View {
        Section("Facebook Live") {
            FacebookLivePanel(
                isConfigured: viewModel.isFacebookConfigured,
                session: viewModel.facebookSession,
                pages: viewModel.facebookPages,
                selectedPageID: viewModel.selectedFacebookPageID,
                isLoading: viewModel.isFacebookLoading,
                statusMessage: viewModel.facebookStatusMessage,
                onSignIn: { viewModel.signInWithFacebook() },
                onAuthorizePages: { viewModel.authorizeFacebookPages() },
                onSignOut: { viewModel.signOutFromFacebook() },
                onSelectPage: { viewModel.selectFacebookPage($0) },
                onPrepareLive: { viewModel.prepareFacebookLive() }
            )
        }
        Section("Destino RTMPS") {
            StreamDestinationPanel(
                destination: $viewModel.streamDestination,
                publisherStats: viewModel.publisherStats,
                isPublishing: viewModel.isPublishing,
                onStart: { viewModel.startPublishing() },
                onStop: { viewModel.stopPublishing() }
            )
        }
    }
}
