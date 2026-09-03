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
                    DirectorInspectorSection("Calidad de video", systemImage: "dial.low") {
                        DirectorVideoQualityPanel(settings: $viewModel.monitorQuality)
                    }

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
                        widgetStudioSection
                    }

                    if !mediaViewModel.liveWidgets.isEmpty
                        || mediaViewModel.fullScreenGraphicResource != nil
                        || mediaViewModel.isPlaylistPlaying {
                        liveGraphicsSection
                    }

                    DirectorInspectorSection("Monitor multiview", systemImage: "display.2") {
                        PreviewMonitorInspectorSummary(
                            layoutName: previewMonitor.settings.layoutMode.displayName,
                            onOpenMonitor: onOpenPreviewMonitor,
                            onConfigure: onConfigurePreviewMonitor
                        )
                    }

                    DirectorInspectorSection("Emisión", systemImage: "dot.radiowaves.up.forward") {
                        VStack(alignment: .leading, spacing: 16) {
                            facebookPanel
                            Divider().overlay(BroadcastTheme.workspaceDivider)
                            streamPanel
                        }
                    }

                    remoteControlsSection
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(BroadcastTheme.panelBackground)
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

    private var widgetStudioSection: some View {
        DirectorInspectorSection("Widget Studio", systemImage: "wand.and.stars") {
            BroadcastWidgetStudioPanel(
                configuration: $mediaViewModel.draftWidgetConfiguration,
                displayName: $mediaViewModel.draftWidgetDisplayName,
                templateTitle: mediaViewModel.draftWidgetConfiguration.resolvedTemplate.title,
                logoURL: mediaViewModel.editingWidgetResource.flatMap { mediaViewModel.logoURL(for: $0) },
                isEditingExisting: mediaViewModel.isEditingExistingWidget,
                isLiveOnAir: mediaViewModel.editingWidgetResource.map {
                    mediaViewModel.liveWidgetIDs.contains($0.id)
                } ?? false,
                isEditingPlacement: mediaViewModel.isWidgetPlacementEditing,
                onEnterPlayMode: { mediaViewModel.enterWidgetPlayPreview() },
                onEnterLayoutMode: { mediaViewModel.enterWidgetLayoutEditing() },
                onImportLogo: { mediaViewModel.requestWidgetLogoImport() },
                onImportLogoFromPhotoLibrary: { mediaViewModel.requestWidgetLogoImportFromPhotoLibrary() },
                onSave: { mediaViewModel.saveDraftWidget() },
                onPreview: { mediaViewModel.previewDraftWidget() },
                onGoLive: { mediaViewModel.takeDraftWidgetLive() },
                onApplyToLive: { mediaViewModel.applyDraftToLiveAir() },
                onRemoveFromLive: {
                    if let id = mediaViewModel.editingWidgetResource?.id {
                        mediaViewModel.removeWidgetFromLive(id)
                    }
                },
                onClose: { mediaViewModel.closeWidgetStudio() }
            )
        }
    }

    private var liveGraphicsSection: some View {
        DirectorInspectorSection("Gráficos al aire", systemImage: "photo.on.rectangle") {
            VStack(alignment: .leading, spacing: 8) {
                if mediaViewModel.isWidgetStudioOpen, !mediaViewModel.isEditingExistingWidget {
                    Label("Preview del widget nuevo", systemImage: "eye")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }

                ForEach(mediaViewModel.liveWidgets) { widget in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(widget.listLabel)
                                .font(.subheadline.weight(.medium))
                            Text(widgetConfigurationLabel(for: widget))
                                .font(.caption2)
                                .foregroundStyle(BroadcastTheme.subtleText)
                        }
                        Spacer()
                        Button("Editar") {
                            mediaViewModel.openWidgetStudio(for: widget)
                        }
                        .buttonStyle(.borderless)
                        Button(role: .destructive) {
                            mediaViewModel.removeWidgetFromLive(widget.id)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(.borderless)
                    }
                }

                if let fullScreen = mediaViewModel.fullScreenGraphicResource,
                   mediaViewModel.liveFullScreenGraphicID != nil {
                    HStack {
                        Text("Pantalla completa: \(fullScreen.listLabel)")
                            .font(.subheadline)
                        Spacer()
                        Button(role: .destructive) {
                            mediaViewModel.removeFullScreenFromLive()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(.borderless)
                    }
                }

                if mediaViewModel.isPlaylistPlaying {
                    Button("Siguiente en playlist", action: mediaViewModel.playNextInQueue)
                    Button("Detener playlist", role: .destructive, action: mediaViewModel.stopPlaylistPlayback)
                }

                if !mediaViewModel.liveWidgets.isEmpty || mediaViewModel.liveFullScreenGraphicID != nil {
                    Button("Quitar todos", role: .destructive) {
                        mediaViewModel.clearAllGraphicsFromProgram()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var remoteControlsSection: some View {
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

    private var facebookPanel: some View {
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

    private var streamPanel: some View {
        StreamDestinationPanel(
            destination: $viewModel.streamDestination,
            publisherStats: viewModel.publisherStats,
            isPublishing: viewModel.isPublishing,
            onStart: { viewModel.startPublishing() },
            onStop: { viewModel.stopPublishing() }
        )
    }

    private func widgetConfigurationLabel(for widget: BroadcastResource) -> String {
        mediaViewModel.loadedConfiguration(for: widget)?.resolvedTemplate.title ?? "Widget"
    }
}
