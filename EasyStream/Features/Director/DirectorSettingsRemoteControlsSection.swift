import SwiftUI
import EasyStreamUIComponents

struct DirectorSettingsRemoteControlsSection: View {
    let viewModel: DirectorSessionViewModel

    var body: some View {
        if let sourceID = viewModel.inspectorSourceID {
            DirectorInspectorSection("Controles remotos", systemImage: "slider.horizontal.3") {
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
            DirectorInspectorSection("Controles remotos", systemImage: "slider.horizontal.3") {
                BroadcastInspectorEmptyState("Sin cámara seleccionada", systemImage: "hand.tap")
            }
        }
    }
}

struct DirectorSettingsEmissionSection: View {
    @Bindable var viewModel: DirectorSessionViewModel

    var body: some View {
        DirectorInspectorSection("Emisión", systemImage: "dot.radiowaves.up.forward") {
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
                    destination: $viewModel.streamDestination,
                    publisherStats: viewModel.publisherStats,
                    isPublishing: viewModel.isPublishing,
                    onStart: { viewModel.startPublishing() },
                    onStop: { viewModel.stopPublishing() }
                )
            }
        }
    }
}
