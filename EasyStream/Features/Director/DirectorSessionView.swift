import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorSessionView: View {
    @State private var viewModel = DirectorSessionViewModel()
    @Bindable private var previewMonitor = DirectorPreviewMonitorStore.shared
    private let identity = DeviceIdentity.current()
#if os(macOS)
    @Environment(\.openWindow) private var openWindow
#endif

    private enum WorkspaceMetrics {
        static let sidebarWidth: CGFloat = 260
        static let inspectorWidth: CGFloat = 380
    }

    @State private var isPreviewMonitorSettingsPresented = false

    var body: some View {
        @Bindable var viewModel = viewModel

        Group {
            if viewModel.needsLocalNetworkPermission {
                LocalNetworkPermissionView(openSettings: PlatformSettings.openAppSettings)
            } else {
                switcherLayout
            }
        }
        .navigationTitle("Director")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openPreviewMonitor()
                } label: {
                    Label("Monitor", systemImage: "display.2")
                }
                .help("Abrir monitor multiview en segunda pantalla")
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    isPreviewMonitorSettingsPresented = true
                } label: {
                    Label("Ajustes monitor", systemImage: "slider.horizontal.3")
                }
                .help("Configurar monitor multiview")
            }
        }
        .onAppear {
            viewModel.start(identity: identity)
            previewMonitor.bind { viewModel.selectPreview($0) }
        }
        .onDisappear {
            previewMonitor.unbind()
            viewModel.stop()
        }
#if os(macOS)
        .onKeyPress(.space) {
            viewModel.takeToProgram()
            return .handled
        }
        .background(keyboardShortcuts)
#endif
        .sheet(isPresented: $isPreviewMonitorSettingsPresented) {
            PreviewMonitorSettingsSheet(
                settings: $previewMonitor.settings,
                onOpenMonitor: openPreviewMonitor
            )
        }
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

    /// Three fixed columns: sources | switcher | inspector. The switcher width is computed
    /// from the remaining space so WebRTC views cannot expand over the inspector.
    private var directorWorkspaceLayout: some View {
        GeometryReader { geometry in
            let switcherWidth = max(
                0,
                geometry.size.width - WorkspaceMetrics.sidebarWidth - WorkspaceMetrics.inspectorWidth
            )

            HStack(spacing: 0) {
                sourceSidebar
                    .frame(width: WorkspaceMetrics.sidebarWidth)

                switcherDetailColumn
                    .frame(width: switcherWidth)
                    .layoutPriority(0)
                    .clipped()

                inspectorPanel
                    .frame(width: WorkspaceMetrics.inspectorWidth)
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(2)
                    .zIndex(1)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
            .clipped()
        }
    }

    private var switcherDetailColumn: some View {
        VStack(spacing: 0) {
            DirectorStatusBar(
                connectedCameras: viewModel.connectedSourceCount,
                programName: programDisplayName,
                isLive: viewModel.connectedSourceCount > 0,
                encoderStats: viewModel.encoderStats,
                audioEncoderStats: viewModel.audioEncoderStats
            )
            mainSwitcherArea
                .layoutPriority(1)
            takeBar
        }
        .frame(maxHeight: .infinity)
        .clipped()
        .background(BroadcastTheme.panelBackground)
    }

#if os(macOS)
    private func openPreviewMonitor() {
        openWindow(id: "preview-monitor")
        PreviewMonitorWindowPlacement.applyExternalDisplayPreference(previewMonitor.settings.openOnExternalDisplay)
        previewMonitor.restartPaginationIfNeeded()
    }
#else
    private func openPreviewMonitor() {
        previewMonitor.restartPaginationIfNeeded()
    }
#endif

    private var compactLayout: some View {
        List {
            statusSection
            programSection
            previewGridSection
            transitionSection
            takeSection
            destinationSection
            inspectorSection
            sourceSidebarSection
        }
#if os(macOS)
        .listStyle(.inset)
#endif
    }

    private var sourceSidebar: some View {
        DirectorSourcesPanel {
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
                        onSelect: { viewModel.selectPreview(source.id) }
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

    private var inspectorPanel: some View {
        DirectorInspectorPanel {
            DirectorInspectorSection("Monitor multiview", systemImage: "display.2") {
                PreviewMonitorInspectorSummary(
                    layoutName: previewMonitor.settings.layoutMode.displayName,
                    onOpenMonitor: openPreviewMonitor,
                    onConfigure: { isPreviewMonitorSettingsPresented = true }
                )
            }

            DirectorInspectorSection("Emisión", systemImage: "dot.radiowaves.up.forward") {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Facebook Live", systemImage: "f.circle.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(BroadcastTheme.subtleText)
                        destinationPanelFacebook
                    }

                    Divider().overlay(BroadcastTheme.workspaceDivider)

                    destinationPanelStream
                }
            }

            if let sourceID = viewModel.inspectorSourceID {
                DirectorInspectorSection("Controles remotos", systemImage: "slider.horizontal.3") {
                    DirectorRemoteControlsView(
                        cameraName: viewModel.inspectorSourceName(for: sourceID),
                        settings: viewModel.settings(for: sourceID),
                        onMutedChange: { viewModel.setMuted($0, for: sourceID) },
                        onZoomChange: { viewModel.setZoom($0, for: sourceID) },
                        onExposureChange: { viewModel.setExposureBias($0, for: sourceID) },
                        onWhiteBalanceChange: { viewModel.setWhiteBalance($0, for: sourceID) },
                        onLensChange: { viewModel.setLens($0, for: sourceID) }
                    )
                }
            } else {
                DirectorInspectorSection("Controles remotos", systemImage: "slider.horizontal.3") {
                    BroadcastInspectorEmptyState("Sin cámara seleccionada", systemImage: "hand.tap")
                }
            }
        }
        .frame(width: WorkspaceMetrics.inspectorWidth)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .clipped()
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
                                track: source.videoTrack,
                                isPreview: source.id == viewModel.previewSourceID,
                                isProgram: source.id == viewModel.programSourceID,
                                isConnected: source.connectionState == .connected,
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
            }
        }
    }

    @ViewBuilder
    private var programVideoContent: some View {
        if let displayTrack = viewModel.programDisplayTrack {
            TransitionProgramView(
                outgoingTrack: viewModel.isTransitioning ? viewModel.outgoingProgramVideoTrack : nil,
                incomingTrack: displayTrack,
                progress: viewModel.isTransitioning ? viewModel.transitionProgress : 1,
                kind: viewModel.selectedTransition.kind
            )
        } else {
            ContentUnavailableView {
                Label("Sin programa", systemImage: "tv.slash")
            } description: {
                Text(viewModel.statusMessage)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white.opacity(0.7))
        }
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
    private var destinationPanelFacebook: some View {
        @Bindable var viewModel = viewModel
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

    @ViewBuilder
    private var destinationPanelStream: some View {
        @Bindable var viewModel = viewModel
        StreamDestinationPanel(
            destination: $viewModel.streamDestination,
            publisherStats: viewModel.publisherStats,
            isPublishing: viewModel.isPublishing,
            onStart: { viewModel.startPublishing() },
            onStop: { viewModel.stopPublishing() }
        )
    }

    @ViewBuilder
    private var destinationPanel: some View {
        @Bindable var viewModel = viewModel
        VStack(alignment: .leading, spacing: 20) {
            destinationPanelFacebook
            Divider()
            destinationPanelStream
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                    track: source.videoTrack,
                    isPreview: source.id == viewModel.previewSourceID,
                    isProgram: source.id == viewModel.programSourceID,
                    isConnected: source.connectionState == .connected,
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

    @ViewBuilder
    private var inspectorSection: some View {
        if let sourceID = viewModel.inspectorSourceID {
            Section("Controles remotos") {
                DirectorRemoteControlsView(
                    cameraName: viewModel.inspectorSourceName(for: sourceID),
                    settings: viewModel.settings(for: sourceID),
                    onMutedChange: { viewModel.setMuted($0, for: sourceID) },
                    onZoomChange: { viewModel.setZoom($0, for: sourceID) },
                    onExposureChange: { viewModel.setExposureBias($0, for: sourceID) },
                    onWhiteBalanceChange: { viewModel.setWhiteBalance($0, for: sourceID) },
                    onLensChange: { viewModel.setLens($0, for: sourceID) }
                )
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
        guard let preview = viewModel.previewSourceID,
              let program = viewModel.programSourceID else { return false }
        return preview != program
    }

    private var programDisplayName: String? {
        guard let id = viewModel.programSourceID else { return nil }
        return viewModel.sources.first { $0.id == id }?.displayName
    }

    private var previewSelection: Binding<CameraSourceID?> {
        Binding(
            get: { viewModel.previewSourceID },
            set: { newValue in
                if let newValue { viewModel.selectPreview(newValue) }
            }
        )
    }

    private func sourceRow(_ source: ConnectedCameraSource) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(source.displayName)
                    .font(.headline)
                HStack(spacing: 8) {
                    if source.id == viewModel.previewSourceID {
                        Text(BroadcastTerminology.previewShort)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.green)
                    }
                    if source.id == viewModel.programSourceID {
                        Text(BroadcastTerminology.programShort)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.red)
                    }
                    if source.id == viewModel.programAudioSourceID {
                        Text(BroadcastTerminology.audioShort)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.blue)
                    }
                }
            }
            Spacer()
            ConnectionStatusBadge(
                isActive: source.connectionState == .connected,
                label: source.connectionState == .connected ? "Live" : "…"
            )
        }
        .contentShape(Rectangle())
        .onTapGesture { viewModel.selectPreview(source.id) }
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
