import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Studio tab — audio, intercom, graphics, emission, remote camera controls.
struct DirectorSettingsStudioTab: View {
    @Bindable var viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    @Bindable var intercomService: TeamIntercomService

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 14) {
                DirectorInspectorSection("Audio de programa", systemImage: "waveform") {
                    ProgramAudioSourcePanel(
                        sources: viewModel.sources.map {
                            ProgramAudioSourcePanel.SourceOption(
                                id: $0.id,
                                name: $0.displayName,
                                isConnected: $0.connectionState == .connected
                            )
                        },
                        programAudioSourceID: viewModel.programAudioSourceID,
                        onSelect: { viewModel.setProgramAudioSource($0) }
                    )
                }

                DirectorInspectorSection("Intercom", systemImage: "mic.fill") {
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

                if mediaViewModel.isWidgetStudioOpen {
                    DirectorSettingsWidgetStudioSection(mediaViewModel: mediaViewModel)
                }

                if !mediaViewModel.liveWidgets.isEmpty
                    || mediaViewModel.fullScreenGraphicResource != nil
                    || mediaViewModel.isPlaylistPlaying {
                    DirectorSettingsLiveGraphicsSection(mediaViewModel: mediaViewModel)
                }

                DirectorSettingsEmissionSection(viewModel: viewModel)

                DirectorSettingsRemoteControlsSection(viewModel: viewModel)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
