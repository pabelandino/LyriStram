import SwiftUI
import UniformTypeIdentifiers
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

struct DirectorSessionView: View {
    @State private var viewModel = DirectorSessionViewModel()
    @State private var mediaViewModel = BroadcastMediaViewModel()
    @State private var intercomService = TeamIntercomService()
    @State private var sidebarTab: DirectorSidebarTab = .cameras
    @Bindable private var previewMonitor = DirectorPreviewMonitorStore.shared
    @Bindable private var programOutputStore = DirectorProgramOutputStore.shared
    @Bindable private var liveProgramAir = LiveProgramAirStore.shared
    private let identity = DeviceIdentity.current()
#if os(macOS)
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
#endif

    @State private var isPreviewMonitorSettingsPresented = false
    @State private var isStreamSettingsPresented = false
    @State private var isDirectorSettingsPresented = false
    @State private var isVideoQualitySettingsPresented = false

    private enum WorkspaceMetrics {
        static let sidebarWidth: CGFloat = 260
        static let libraryRailWidth: CGFloat = 272
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Group {
            if viewModel.needsLocalNetworkPermission {
                LocalNetworkPermissionView(
                    openSettings: PlatformSettings.openAppSettings,
                    onRetry: { viewModel.retryLocalNetworkAccess(identity: identity) }
                )
            } else {
                switcherLayout
            }
        }
        .navigationTitle("")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#if os(macOS)
        .broadcastHiddenWindowToolbar()
#endif
        .toolbar {
#if os(macOS)
            ToolbarItemGroup(placement: .primaryAction) {
                BroadcastTransmissionMenu(
                    programOutputSettings: $programOutputStore.settings,
                    availableScreens: ProgramOutputDisplayDiscovery.availableScreens(),
                    isExternalOutputLive: programOutputStore.isWindowOpen,
                    isNetworkPublishing: viewModel.isPublishing,
                    isFacebookConfigured: viewModel.isFacebookConfigured,
                    isFacebookLoading: viewModel.isFacebookLoading,
                    facebookStatusMessage: viewModel.facebookStatusMessage,
                    streamDestination: viewModel.streamDestination,
                    onStartExternalOutput: startExternalBroadcast,
                    onStopExternalOutput: stopExternalBroadcast,
                    onPrepareFacebookLive: { viewModel.prepareFacebookLive() },
                    onStartNetworkPublish: { viewModel.startPublishing() },
                    onStopNetworkPublish: { viewModel.stopPublishing() },
                    onOpenStreamSettings: { openStreamSettings() }
                )

                Button {
                    openVideoQualitySettings()
                } label: {
                    Label("Calidad", systemImage: "dial.low")
                }
                .help("Tiles preview, monitor PROG y salida en vivo")

                Button {
                    openDirectorSettings()
                } label: {
                    Label("Ajustes", systemImage: "gearshape")
                }
                .help("Audio, intercom, gráficos y emisión")

                Button {
                    openPreviewMonitor()
                } label: {
                    Label("Monitor", systemImage: "display.2")
                }
                .help("Abrir monitor multiview en segunda pantalla")

                Button {
                    openPreviewMonitorSettings()
                } label: {
                    Label("Ajustes monitor", systemImage: "slider.horizontal.3")
                }
                .help("Configurar monitor multiview")
            }
#else
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        isVideoQualitySettingsPresented = true
                    } label: {
                        Label("Calidad de video", systemImage: "dial.low")
                    }
                    Button {
                        isDirectorSettingsPresented = true
                    } label: {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                    Button {
                        openPreviewMonitor()
                    } label: {
                        Label("Monitor", systemImage: "display.2")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
#endif
        }
#if os(iOS)
        .sheet(isPresented: $isStreamSettingsPresented) {
            NavigationStack {
                StreamDestinationPanel(
                    destination: $viewModel.streamDestination,
                    publisherStats: viewModel.publisherStats,
                    isPublishing: viewModel.isPublishing,
                    onStart: {
                        viewModel.startPublishing()
                        isStreamSettingsPresented = false
                    },
                    onStop: { viewModel.stopPublishing() }
                )
                .padding()
                .navigationTitle("Destino RTMPS")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Listo") { isStreamSettingsPresented = false }
                    }
                }
            }
        }
#endif
        .onAppear {
            DirectorWorkspaceSession.shared.bind(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                intercomService: intercomService,
                previewMonitor: previewMonitor,
                onOpenPreviewMonitor: openPreviewMonitor,
                onConfigurePreviewMonitor: openPreviewMonitorSettings
            )
            viewModel.start(identity: identity)
            previewMonitor.bind { viewModel.selectPreview($0) }
            mediaViewModel.reload()
            mediaViewModel.refreshLiveAirBus()
            intercomService.start(identity: identity, role: .director)
            liveProgramAir.widgetAutoDismissHandler = { [mediaViewModel] id in
                mediaViewModel.removeWidgetFromLive(id, closeStudioIfEditing: false)
            }
#if os(macOS)
            programOutputStore.resetExternalOutputForLaunch()
#endif
        }
        .onDisappear {
            DirectorWorkspaceSession.shared.unbind()
            previewMonitor.unbind()
            viewModel.stop()
            intercomService.stop()
        }
        .background {
            ProgramOutputSyncBridge(viewModel: viewModel)
        }
#if os(macOS)
        .background(keyboardShortcuts)
#endif
#if os(iOS)
        .sheet(isPresented: $isDirectorSettingsPresented) {
            DirectorSettingsSheet(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                previewMonitor: previewMonitor,
                intercomService: intercomService,
                onOpenPreviewMonitor: openPreviewMonitor,
                onConfigurePreviewMonitor: { isPreviewMonitorSettingsPresented = true }
            )
        }
        .sheet(isPresented: $isVideoQualitySettingsPresented) {
            DirectorVideoQualitySettingsView(
                initialSettings: viewModel.monitorQuality,
                onApply: { settings in
                    viewModel.applyMonitorQuality(settings)
                    isVideoQualitySettingsPresented = false
                },
                onCancel: { isVideoQualitySettingsPresented = false }
            )
        }
        .sheet(isPresented: $isPreviewMonitorSettingsPresented) {
            PreviewMonitorSettingsSheet(
                settings: $previewMonitor.settings,
                onOpenMonitor: openPreviewMonitor
            )
        }
#endif
        .onChange(of: mediaViewModel.isWidgetStudioOpen) { _, isOpen in
            if isOpen {
                openDirectorSettings()
            }
        }
        .sheet(isPresented: $mediaViewModel.isPlaylistEditorPresented) {
            if let playlist = mediaViewModel.editingPlaylist {
                BroadcastPlaylistEditorSheet(
                    name: playlist.name,
                    kind: playlist.kind,
                    itemIDs: playlist.itemIDs,
                    allResources: mediaViewModel.allResources,
                    onSave: { name, kind, itemIDs in
                        var updated = playlist
                        updated.name = name
                        updated.kind = kind
                        updated.itemIDs = itemIDs
                        mediaViewModel.savePlaylist(updated)
                    }
                )
            }
        }
        .sheet(isPresented: $mediaViewModel.isWidgetTemplatePickerPresented) {
            BroadcastWidgetTemplatePickerSheet { template in
                mediaViewModel.openNewWidgetStudio(template: template)
            }
        }
#if os(iOS)
        .fileImporter(
            isPresented: $mediaViewModel.isWidgetLogoImporterPresented,
            allowedContentTypes: [.png],
            allowsMultipleSelection: false
        ) { result in
            guard case .success(let urls) = result, let url = urls.first else { return }
            mediaViewModel.importWidgetLogo(from: url)
        }
        .broadcastMediaPhotoImporter(
            isPresented: $mediaViewModel.isPhotoPickerPresented,
            kind: mediaViewModel.pendingImportKind
        ) { data, ext in
            mediaViewModel.importData(data, kind: mediaViewModel.pendingImportKind, preferredExtension: ext)
        }
        .broadcastWidgetLogoPhotoImporter(
            isPresented: $mediaViewModel.isWidgetLogoPhotoPickerPresented,
            onImport: { mediaViewModel.importWidgetLogoData($0) }
        )
#endif
    }

    @ViewBuilder
    private var switcherLayout: some View {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            directorWorkspaceLayout
        } else {
            compactLayout
        }
#else
        directorWorkspaceLayout
#endif
    }

    /// Three fixed columns: sources | switcher | library rail.
    private var directorWorkspaceLayout: some View {
        HStack(spacing: 0) {
            DirectorSourceSidebarView(
                sidebarTab: $sidebarTab,
                viewModel: viewModel,
                mediaViewModel: mediaViewModel
            )
            .frame(width: WorkspaceMetrics.sidebarWidth)

            DirectorSwitcherColumnView(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                liveProgramAir: liveProgramAir
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)
            .clipped()

            DirectorLibraryRailView(mediaViewModel: mediaViewModel)
                .frame(width: WorkspaceMetrics.libraryRailWidth)
                .layoutPriority(2)
                .clipped()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
#if os(macOS)
        .background(BroadcastTheme.panelBackground)
#endif
    }

#if os(macOS)
    private func openDirectorSettings() {
        openWindow(id: "director-settings")
    }

    private func openStreamSettings() {
        openWindow(id: "director-stream-settings")
    }

    private func openPreviewMonitorSettings() {
        openWindow(id: "director-preview-monitor-settings")
    }

    private func openVideoQualitySettings() {
        openWindow(id: "director-video-quality")
    }
#else
    private func openDirectorSettings() {
        isDirectorSettingsPresented = true
    }

    private func openStreamSettings() {
        isStreamSettingsPresented = true
    }

    private func openPreviewMonitorSettings() {
        isPreviewMonitorSettingsPresented = true
    }

    private func openVideoQualitySettings() {}
#endif

#if os(macOS)
    private func openPreviewMonitor() {
        openWindow(id: "preview-monitor")
        PreviewMonitorWindowPlacement.applyExternalDisplayPreference(previewMonitor.settings.openOnExternalDisplay)
        previewMonitor.restartPaginationIfNeeded()
    }

    private func openProgramOutput() {
        startExternalBroadcast()
    }

    private func startExternalBroadcast() {
#if os(macOS)
        guard ProgramOutputDisplayDiscovery.hasExternalDisplay else { return }
        programOutputStore.sanitizeScreenSelection()
        guard let screenIndex = ProgramOutputDisplayDiscovery.validatedExternalScreenIndex(
            programOutputStore.settings.selectedScreenIndex
        ) else { return }
        programOutputStore.settings.isEnabled = true
        programOutputStore.settings.fillScreen = true
        openWindow(id: "program-output")
        programOutputStore.markWindowOpen()
        ProgramOutputWindowPlacement.presentFullscreen(on: screenIndex)
#else
        programOutputStore.settings.isEnabled = true
        programOutputStore.settings.fillScreen = true
        openWindow(id: "program-output")
        programOutputStore.markWindowOpen()
#endif
    }

    private func stopExternalBroadcast() {
        dismissWindow(id: "program-output")
        programOutputStore.markWindowClosed()
        programOutputStore.settings.isEnabled = false
        ProgramOutputWindowPlacement.restorePresentationOptionsIfNeeded()
    }
#else
    private func openPreviewMonitor() {
        previewMonitor.restartPaginationIfNeeded()
    }

    private func openProgramOutput() {}
#endif

    private var compactLayout: some View {
        DirectorSessionCompactView(
            viewModel: viewModel,
            mediaViewModel: mediaViewModel,
            liveProgramAir: liveProgramAir,
            onOpenSettings: openDirectorSettings
        )
    }

#if os(macOS)
    private var keyboardShortcuts: some View {
        Group {
            ForEach(0..<min(viewModel.sources.count, 9), id: \.self) { index in
                Button("") {
                    if let id = viewModel.source(at: index) {
                        viewModel.selectPreview(id)
                    }
                }
                .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: [])
                .hidden()
            }
        }
    }
#endif
}

#if os(iOS)
import UIKit
#endif

#Preview {
    NavigationStack {
        DirectorSessionView()
    }
}
