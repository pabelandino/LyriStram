import SwiftUI
import LvoqStreamCore
import LvoqStreamUIComponents

struct DirectorSettingsRemoteControlsSection: View {
    let viewModel: DirectorSessionViewModel

    var body: some View {
        if let sourceID = viewModel.inspectorSourceID {
            DirectorInspectorSection(BundleLocalization.string("remote.controls.section"), systemImage: "slider.horizontal.3") {
                DirectorRemoteControlsView(
                    cameraName: viewModel.inspectorSourceName(for: sourceID),
                    settings: viewModel.settings(for: sourceID),
                    connectionState: viewModel.connectionState(for: sourceID),
                    onMutedChange: { viewModel.setMuted($0, for: sourceID) },
                    onZoomChange: { viewModel.setZoom($0, for: sourceID) },
                    onExposureChange: { viewModel.setExposureBias($0, for: sourceID) },
                    onWhiteBalanceChange: { viewModel.setWhiteBalance($0, for: sourceID) },
                    onLensChange: { viewModel.setLens($0, for: sourceID) },
                    onReconnect: { viewModel.reconnectCamera(sourceID) }
                )
            }
        } else {
            DirectorInspectorSection(BundleLocalization.string("remote.controls.section"), systemImage: "slider.horizontal.3") {
                BroadcastInspectorEmptyState(BundleLocalization.string("remote.no_camera_selected"), systemImage: "hand.tap")
            }
        }
    }
}

struct DirectorSettingsEmissionSection: View {
    let viewModel: DirectorSessionViewModel

    var body: some View {
        DirectorInspectorSection(BundleLocalization.string("director.emission.section"), systemImage: "dot.radiowaves.up.forward") {
            TimelineView(.periodic(from: .now, by: 1.0)) { _ in
                VStack(alignment: .leading, spacing: 16) {
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
                    Divider().overlay(BroadcastTheme.workspaceDivider)
                    StreamDestinationPanel(
                        destination: Binding(
                            get: { viewModel.streamDestination },
                            set: { viewModel.streamDestination = $0 }
                        ),
                        publisherStats: viewModel.publisherStats,
                        isPublishing: viewModel.isPublishing,
                        onStart: { viewModel.startPublishing() },
                        onStop: { viewModel.stopPublishing() }
                    )
                }
            }
        }
    }
}
