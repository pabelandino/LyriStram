import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Audio, intercom, and camera controls kept beside the library.
struct DirectorRailHandySettingsView: View {
    let viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    @Bindable var intercomService: TeamIntercomService
    @Environment(\.directorCompactChrome) private var compact

    private var liveVideoAvailable: Bool {
        mediaViewModel.liveFullScreenGraphicID != nil
            && mediaViewModel.fullScreenGraphicResource?.kind == .video
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .font(compact ? .caption : .body)
                    .foregroundStyle(BroadcastTheme.studioAccent)
                Text("Ajustes")
                    .font(compact ? .subheadline.weight(.semibold) : .headline)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, compact ? 10 : 12)
            .padding(.vertical, compact ? 8 : 10)
            .background(BroadcastTheme.panelElevated)

            Divider().overlay(BroadcastTheme.workspaceDivider)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: compact ? 10 : 14) {
                    railBlock("Intercom", systemImage: "mic.fill") {
                        TeamIntercomPanel(
                            peers: intercomService.peers,
                            statusMessage: intercomService.statusMessage,
                            isEnabled: intercomService.isEnabled,
                            isTalking: intercomService.isTalking,
                            isActivating: intercomService.isActivating,
                            targetPeerID: intercomService.targetPeerID,
                            needsLocalNetworkPermission: intercomService.needsLocalNetworkPermission,
                            onOpenSettings: PlatformSettings.openAppSettings,
                            onTargetPeerChange: { intercomService.setTargetPeer($0) },
                            onEnabledChange: { intercomService.isEnabled = $0 },
                            onTalkBegin: { intercomService.toggleTalking() },
                            onTalkEnd: { intercomService.toggleTalking() }
                        )
                    }

                    railBlock("Audio", systemImage: "waveform") {
                        DirectorProgramAudioSettingsView(
                            viewModel: viewModel,
                            liveVideoAvailable: liveVideoAvailable,
                            monitor: ProgramAudioMonitor.shared
                        )
                    }

                    DirectorConnectAddressCard(
                        addresses: viewModel.localIPv4Addresses,
                        port: viewModel.listeningPort,
                        activeHost: viewModel.advertisedConnectHost,
                        onApply: { viewModel.applyAdvertisedConnectHost($0) }
                    )

                    if !mediaViewModel.liveWidgets.isEmpty
                        || mediaViewModel.fullScreenGraphicResource != nil {
                        DirectorSettingsLiveGraphicsSection(mediaViewModel: mediaViewModel)
                    }

                    DirectorSettingsRemoteControlsSection(viewModel: viewModel)
                }
                .padding(compact ? 8 : 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BroadcastTheme.panelBackground)
    }

    private func railBlock<Content: View>(
        _ title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(compact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))
                .foregroundStyle(BroadcastTheme.primaryText)
                .lineLimit(1)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
