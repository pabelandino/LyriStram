import SwiftUI
import UniformTypeIdentifiers
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

struct DirectorSessionView: View {
    @State var viewModel = DirectorSessionViewModel()
    @State var mediaViewModel = BroadcastMediaViewModel()
    @State var intercomService = TeamIntercomService()
    @Bindable var previewMonitor = DirectorPreviewMonitorStore.shared
    @Bindable var programOutputStore = DirectorProgramOutputStore.shared
    @Bindable var liveProgramAir = LiveProgramAirStore.shared
    let identity = DeviceIdentity.current()
    var onLeaveRole: () -> Void = {}

#if os(macOS)
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
#endif
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State var isStreamSettingsPresented = false
    @State var isStudioSettingsPresented = false
    @State var isPreviewMonitorPresented = false
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
            viewModel.syncAudioWithProgramPlate(videoID: programPlateVideoID)
            platformDirectorSessionDidAppear()
            scheduleStudioSettingsPrewarm()
        }
        .onDisappear {
            DirectorWorkspaceSession.shared.unbind()
            previewMonitor.unbind()
            viewModel.stop()
            intercomService.stop()
        }
        .onChange(of: programPlateVideoID) { _, videoID in
            viewModel.syncAudioWithProgramPlate(videoID: videoID)
        }
        .background {
            ProgramOutputSyncBridge(viewModel: viewModel)
        }
        .background {
            DirectorWidgetStudioPresentationHost(mediaViewModel: mediaViewModel)
        }
        .background {
            DirectorPreviewMonitorPresentationHost(isPresented: $isPreviewMonitorPresented)
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
        .sheet(isPresented: $mediaViewModel.isWidgetTemplatePickerPresented) {
            BroadcastWidgetTemplatePickerSheet { template in
                mediaViewModel.openNewWidgetStudio(template: template)
                platformOpenWidgetStudioWindow()
            }
        }
    }

    func presentWidgetTemplatePicker() {
        DirectorModalPresentation.afterYield {
            mediaViewModel.isWidgetTemplatePickerPresented = true
        }
    }

    private var programPlateVideoID: UUID? {
        guard liveProgramAir.fullScreenIsLive, liveProgramAir.fullScreenResource?.kind == .video else { return nil }
        return liveProgramAir.fullScreenResource?.id
    }

    /// Three columns when the inner display is open. Preview and program move above the crease when it is half folded.
    var directorWorkspaceLayout: some View {
        DirectorAdaptiveWorkspaceView(
            viewModel: viewModel,
            mediaViewModel: mediaViewModel,
            intercomService: intercomService,
            liveProgramAir: liveProgramAir,
            onLeaveRole: onLeaveRole,
            onCreateWidget: presentWidgetTemplatePicker,
            onOpenSettings: { openStudioSettings() },
            onOpenMonitor: { openPreviewMonitor() }
        )
    }

    var compactLayout: some View {
        DirectorSessionCompactView(
            viewModel: viewModel,
            mediaViewModel: mediaViewModel,
            intercomService: intercomService,
            liveProgramAir: liveProgramAir,
            onOpenSettings: { openStudioSettings() },
            onCreateWidget: presentWidgetTemplatePicker
        )
    }

    func scheduleStudioSettingsPrewarm() {
        guard !DirectorWorkspaceSession.shared.hasPrewarmedSettingsUI else { return }

        Task { @MainActor in
            await DirectorModalPresentation.deferHeavyUI()
            shouldPrewarmStudioSettings = true
            await DirectorModalPresentation.deferHeavyUI()
            await DirectorModalPresentation.deferHeavyUI()
            shouldPrewarmStudioSettings = false
            DirectorWorkspaceSession.shared.markSettingsUIPrewarmed()
        }
    }
}

#Preview {
    NavigationStack {
        DirectorSessionView()
    }
}
