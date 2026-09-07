import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Director workspace settings — quality, audio, intercom, emission, remote controls.
struct DirectorSettingsSheet: View {
    @Bindable var viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    @Bindable var previewMonitor: DirectorPreviewMonitorStore
    let intercomService: TeamIntercomService
    let onOpenPreviewMonitor: () -> Void
    let onConfigurePreviewMonitor: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
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

                    DirectorInspectorSection("Monitor multiview", systemImage: "display.2") {
                        PreviewMonitorInspectorSummary(
                            layoutName: previewMonitor.settings.layoutMode.displayName,
                            onOpenMonitor: onOpenPreviewMonitor,
                            onConfigure: onConfigurePreviewMonitor
                        )
                    }

                    DirectorSettingsEmissionSection(viewModel: viewModel)

                    DirectorSettingsRemoteControlsSection(viewModel: viewModel)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(BroadcastTheme.panelBackground)
            .broadcastStudioChrome()
            .navigationTitle("Ajustes")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 460, minHeight: 620)
#endif
    }
}
