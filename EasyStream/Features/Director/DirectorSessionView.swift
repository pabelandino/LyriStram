import SwiftUI
import UniformTypeIdentifiers
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

struct DirectorSessionView: View {
    @State var viewModel = DirectorSessionViewModel()
    @State var mediaViewModel = BroadcastMediaViewModel()
    @State var intercomService = TeamIntercomService()
    @State var sidebarTab: DirectorSidebarTab = .cameras
    @Bindable var previewMonitor = DirectorPreviewMonitorStore.shared
    @Bindable var programOutputStore = DirectorProgramOutputStore.shared
    @Bindable var liveProgramAir = LiveProgramAirStore.shared
    let identity = DeviceIdentity.current()

#if os(macOS)
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
#endif

    @State var isStreamSettingsPresented = false
    @State var isStudioSettingsPresented = false
    @State var studioSettingsInitialTab: DirectorStudioSettingsTab = .studio
    @State var shouldPrewarmStudioSettings = false

    enum WorkspaceMetrics {
        static let sidebarWidth: CGFloat = 260
        static let libraryRailWidth: CGFloat = 272
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        platformDirectorBody
    }

    var sessionContent: some View {
        Group {
            if viewModel.needsLocalNetworkPermission {
                LocalNetworkPermissionView(
                    openSettings: PlatformSettings.openAppSettings,
                    onRetry: { viewModel.retryLocalNetworkAccess(identity: identity) }
                )
            } else {
                platformSwitcherLayout
            }
        }
        .navigationTitle("")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar { platformDirectorToolbar }
        .onAppear {
            DirectorWorkspaceSession.shared.bind(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                intercomService: intercomService,
                previewMonitor: previewMonitor,
                onOpenPreviewMonitor: openPreviewMonitor,
                onConfigurePreviewMonitor: { openStudioSettings(tab: .monitor) }
            )
            viewModel.start(identity: identity)
            previewMonitor.bind { viewModel.selectPreview($0) }
            mediaViewModel.reload()
            mediaViewModel.refreshLiveAirBus()
            intercomService.start(identity: identity, role: .director)
            liveProgramAir.widgetAutoDismissHandler = { [mediaViewModel] id in
                mediaViewModel.removeWidgetFromLive(id, closeStudioIfEditing: false)
            }
            platformDirectorSessionDidAppear()
            scheduleStudioSettingsPrewarm()
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
        .background {
            if shouldPrewarmStudioSettings {
                DirectorStudioSettingsPrewarmShell(
                    viewModel: viewModel,
                    mediaViewModel: mediaViewModel,
                    previewMonitor: previewMonitor,
                    intercomService: intercomService
                )
            }
        }
        .onChange(of: mediaViewModel.isWidgetStudioOpen) { _, isOpen in
            if isOpen {
                openStudioSettings(tab: .studio)
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
    }

    /// Three fixed columns: sources | switcher | library rail.
    var directorWorkspaceLayout: some View {
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
    }

    var compactLayout: some View {
        DirectorSessionCompactView(
            viewModel: viewModel,
            mediaViewModel: mediaViewModel,
            liveProgramAir: liveProgramAir,
            onOpenSettings: { openStudioSettings() }
        )
    }

    func scheduleStudioSettingsPrewarm() {
        guard !DirectorWorkspaceSession.shared.hasPrewarmedSettingsUI else {
            shouldPrewarmStudioSettings = true
            return
        }

        Task { @MainActor in
            await DirectorModalPresentation.deferHeavyUI()
            shouldPrewarmStudioSettings = true
            DirectorWorkspaceSession.shared.markSettingsUIPrewarmed()
            platformPrewarmStudioSettingsWindowIfNeeded()
        }
    }
}

#Preview {
    NavigationStack {
        DirectorSessionView()
    }
}
