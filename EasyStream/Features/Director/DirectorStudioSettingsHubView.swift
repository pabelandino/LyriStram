import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Unified director settings — quality, multiview monitor, and studio controls in one surface.
struct DirectorStudioSettingsHubView: View {
    @Bindable var viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    @Bindable var previewMonitor: DirectorPreviewMonitorStore
    @Bindable var intercomService: TeamIntercomService

    let initialTab: DirectorStudioSettingsTab
    let onOpenPreviewMonitor: () -> Void
    let onDone: () -> Void

    @State var selectedTab: DirectorStudioSettingsTab
    @State var draftVideoQuality: DirectorMonitorQualitySettings

#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var platformHorizontalSizeClass: UserInterfaceSizeClass? {
        horizontalSizeClass
    }
#else
    var platformHorizontalSizeClass: UserInterfaceSizeClass? {
        nil
    }
#endif

    init(
        viewModel: DirectorSessionViewModel,
        mediaViewModel: BroadcastMediaViewModel,
        previewMonitor: DirectorPreviewMonitorStore,
        intercomService: TeamIntercomService,
        initialTab: DirectorStudioSettingsTab = .studio,
        onOpenPreviewMonitor: @escaping () -> Void,
        onDone: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.mediaViewModel = mediaViewModel
        self.previewMonitor = previewMonitor
        self.intercomService = intercomService
        self.initialTab = initialTab
        self.onOpenPreviewMonitor = onOpenPreviewMonitor
        self.onDone = onDone
        _selectedTab = State(initialValue: initialTab)
        _draftVideoQuality = State(initialValue: viewModel.monitorQuality)
    }

    var hasPendingVideoChanges: Bool {
        draftVideoQuality != viewModel.monitorQuality
    }

    var body: some View {
        DirectorStudioSettingsHubPlatformLayout.content(
            selectedTab: $selectedTab,
            horizontalSizeClass: platformHorizontalSizeClass,
            detailContent: detailPane(for:)
        )
            .broadcastStudioChrome()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        commitVideoQualityIfNeeded()
                        onDone()
                    }
                }
            }
            .directorStudioSettingsHubWindowSizing()
            .onAppear {
                selectedTab = initialTab
                draftVideoQuality = viewModel.monitorQuality
            }
    }

    @ViewBuilder
    func detailPane(for tab: DirectorStudioSettingsTab) -> some View {
        switch tab {
        case .video:
            videoTab
        case .monitor:
            monitorTab
        case .studio:
            DirectorSettingsStudioTab(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                intercomService: intercomService
            )
        }
    }

    private var videoTab: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 14) {
                DirectorStudioSettingsInfoCallout(
                    text: "Los presets de calidad se aplican al pulsar «Listo». El monitor PROG no cambia mientras exploras opciones."
                )

                DirectorVideoQualityPanel(settings: $draftVideoQuality)

                if hasPendingVideoChanges {
                    Button("Descartar cambios de calidad") {
                        draftVideoQuality = viewModel.monitorQuality
                    }
                    .buttonStyle(BroadcastGlassBorderedButtonStyle())
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var monitorTab: some View {
        ScrollView(.vertical, showsIndicators: true) {
            PreviewMonitorSettingsForm(
                settings: $previewMonitor.settings,
                onOpenMonitor: onOpenPreviewMonitor
            )
            .padding(.horizontal, 4)
        }
    }

    func commitVideoQualityIfNeeded() {
        guard hasPendingVideoChanges else { return }
        viewModel.applyMonitorQuality(draftVideoQuality)
    }
}
