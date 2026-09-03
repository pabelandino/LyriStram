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
        .onAppear {
            mediaViewModel.refreshLiveAirBus()
        }
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
                    onOpenStreamSettings: { isStreamSettingsPresented = true }
                )

                Button {
                    isDirectorSettingsPresented = true
                } label: {
                    Label("Ajustes", systemImage: "gearshape")
                }
                .help("Calidad, audio, intercom y emisión")

                Button {
                    openPreviewMonitor()
                } label: {
                    Label("Monitor", systemImage: "display.2")
                }
                .help("Abrir monitor multiview en segunda pantalla")

                Button {
                    isPreviewMonitorSettingsPresented = true
                } label: {
                    Label("Ajustes monitor", systemImage: "slider.horizontal.3")
                }
                .help("Configurar monitor multiview")
            }
#else
            ToolbarItem(placement: .primaryAction) {
                Menu {
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
#if os(macOS)
            .frame(minWidth: 420, minHeight: 280)
#endif
        }
        .onAppear {
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
        .onChange(of: mediaViewModel.isWidgetStudioOpen) { _, isOpen in
            if isOpen {
                isDirectorSettingsPresented = true
            }
        }
        .sheet(isPresented: $isPreviewMonitorSettingsPresented) {
            PreviewMonitorSettingsSheet(
                settings: $previewMonitor.settings,
                onOpenMonitor: openPreviewMonitor
            )
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

    /// Three fixed columns: sources | switcher | library rail. The switcher width is computed
    /// from the remaining space so WebRTC views cannot expand over the library rail.
    private var directorWorkspaceLayout: some View {
        GeometryReader { geometry in
            let switcherWidth = max(
                0,
                geometry.size.width - WorkspaceMetrics.sidebarWidth - WorkspaceMetrics.libraryRailWidth
            )

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
                .frame(width: switcherWidth)
                .layoutPriority(0)
                .clipped()

                DirectorLibraryRailView(mediaViewModel: mediaViewModel)
                    .frame(width: WorkspaceMetrics.libraryRailWidth)
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(2)
                    .zIndex(1)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
            .clipped()
        }
#if os(macOS)
        .background(BroadcastTheme.panelBackground)
#endif
    }

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
        List {
            statusSection
            programSection
            previewGridSection
            transitionSection
            takeSection
            destinationSection
            librarySection
            settingsSection
            sourceSidebarSection
        }
#if os(macOS)
        .listStyle(.inset)
#endif
    }

    private var sourceSidebar: some View {
        DirectorSourcesPanel(title: sidebarTab.title) {
            DirectorLeftSidebarTabPicker(selection: $sidebarTab)

            switch sidebarTab {
            case .cameras:
                camerasSidebarContent
            case .playlists:
                playlistsSidebarContent
            case .library:
                EmptyView()
            }
        }
    }

    private var camerasSidebarContent: some View {
        Group {
            BroadcastSectionHeader("Cámaras", systemImage: "video")

            if viewModel.sources.isEmpty {
                Text("Esperando cámaras…")
                    .font(.subheadline)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .padding(.horizontal, 8)
            } else {
                ForEach(viewModel.sources) { source in
                    DirectorSourceListRow(
                        name: source.displayName,
                        isPreview: source.id == viewModel.previewSourceID,
                        isProgram: source.id == viewModel.programSourceID,
                        isAudio: source.id == viewModel.programAudioSourceID,
                        isConnected: source.connectionState == .connected,
                        isSelected: source.id == viewModel.previewSourceID,
                        onSelect: { viewModel.selectPreview(source.id) },
                        onReconnect: source.connectionState != .connected
                            ? { viewModel.reconnectCamera(source.id) }
                            : nil
                    )
                }
            }

            if !viewModel.devices.isEmpty {
                BroadcastSectionHeader("En red", systemImage: "wifi")
                    .padding(.top, 8)
                ForEach(viewModel.devices) { device in
                    DiscoveredDeviceRow(device: device)
                        .padding(.horizontal, 4)
                }
            }
        }
    }

    @ViewBuilder
    private var playlistsSidebarContent: some View {
        BroadcastPlaylistPanel(
            playlists: mediaViewModel.playlists,
            allResources: mediaViewModel.allResources,
            activePlaylistID: mediaViewModel.activePlaylistID,
            isPlaying: mediaViewModel.isPlaylistPlaying,
            queueLabel: mediaViewModel.playlistQueueLabel,
            onCreatePlaylist: {
                mediaViewModel.editingPlaylist = BroadcastPlaylist(name: "Nueva playlist", kind: .mixed)
                mediaViewModel.isPlaylistEditorPresented = true
            },
            onEditPlaylist: { playlist in
                mediaViewModel.editingPlaylist = playlist
                mediaViewModel.isPlaylistEditorPresented = true
            },
            onDeletePlaylist: { mediaViewModel.deletePlaylist($0) },
            onPlayPlaylist: { mediaViewModel.playPlaylist($0) },
            onStopPlayback: { mediaViewModel.stopPlaylistPlayback() },
            onPlayNext: { mediaViewModel.playNextInQueue() }
        )
    }

    private var librarySection: some View {
        Section("Biblioteca") {
            DirectorLibraryRailView(mediaViewModel: mediaViewModel)
                .listRowInsets(EdgeInsets())
        }
    }

    private var settingsSection: some View {
        Section {
            Button {
                isDirectorSettingsPresented = true
            } label: {
                Label("Ajustes del director", systemImage: "gearshape")
            }
        }
    }

    private var mainSwitcherArea: some View {
        VStack(spacing: 16) {
            previewGrid
                .frame(height: 220)

            programOutput
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.92))
        .clipped()
#if os(macOS)
        .focusable()
        .onKeyPress(.space) {
            guard canTake, !viewModel.isTransitioning else { return .ignored }
            viewModel.takeToProgram()
            return .handled
        }
#endif
    }

    private var previewGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(BroadcastTerminology.previewName.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if viewModel.sources.isEmpty {
                ContentUnavailableView("Sin cámaras", systemImage: "video.slash")
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
            } else {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 12) {
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
                            .frame(width: 200, height: 112)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }

    private var programOutput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(BroadcastTerminology.programName.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            ZStack {
                programVideoContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .animation(nil, value: viewModel.isTransitioning)
                    .animation(nil, value: viewModel.transitionProgress)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.red, lineWidth: 3)
                    }
                    .overlay(alignment: .topLeading) {
                        if let name = programDisplayName {
                            Text("\(BroadcastTerminology.programShort) · \(name)")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.red, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundStyle(.white)
                                .padding(12)
                        }
                    }
                    .overlay {
                        DirectorProgramPreviewOverlayView(mediaViewModel: mediaViewModel)
                    }
                    .overlay {
                        DirectorProgramStudioHintsOverlay(mediaViewModel: mediaViewModel)
                    }
            }
        }
    }

    @ViewBuilder
    private var programVideoContent: some View {
        DirectorProgramLiveMonitorView(
            viewModel: viewModel,
            liveProgramAir: liveProgramAir,
            studioPreviewWidgetID: mediaViewModel.isWidgetStudioOpen
                ? mediaViewModel.editingWidgetResource?.id
                : nil
        )
    }

    private var takeBar: some View {
        VStack(spacing: 12) {
            SwitchTransitionControls(transition: $viewModel.selectedTransition)
                .padding(.horizontal, 16)

            TakeToProgramButton(isEnabled: canTake && !viewModel.isTransitioning) {
                viewModel.takeToProgram()
            }
            .padding(.horizontal, 16)

            Text(BroadcastTerminology.takeDescription + " · El audio de programa permanece en su fuente asignada")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .background(.bar)
    }

    @ViewBuilder
    private var destinationSection: some View {
        @Bindable var viewModel = viewModel
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

    // MARK: - Compact (iPhone fallback)

    private var statusSection: some View {
        Section {
            Label(viewModel.statusMessage, systemImage: "antenna.radiowaves.left.and.right")
        }
    }

    private var programSection: some View {
        Section("Programa") {
            programVideoContent
                .aspectRatio(16 / 9, contentMode: .fit)
                .listRowInsets(EdgeInsets())
        }
    }

    private var previewGridSection: some View {
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
    }

    private var transitionSection: some View {
        Section("Transición") {
            SwitchTransitionControls(transition: $viewModel.selectedTransition)
        }
    }

    private var takeSection: some View {
        Section {
            TakeToProgramButton(isEnabled: canTake && !viewModel.isTransitioning) {
                viewModel.takeToProgram()
            }
        }
    }

    private var sourceSidebarSection: some View {
        Section("En red") {
            ForEach(viewModel.devices) { device in
                DiscoveredDeviceRow(device: device)
            }
        }
    }

    // MARK: - Helpers

    private var canTake: Bool {
        guard let preview = viewModel.previewSourceID else { return false }
        if let program = viewModel.programSourceID, preview == program { return false }
        return true
    }

    private var programDisplayName: String? {
        guard let id = viewModel.programSourceID else { return nil }
        return viewModel.sources.first { $0.id == id }?.displayName
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
