import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Mounts heavy settings panels off-screen once so the first user-open does not stall PROG Metal.
struct DirectorStudioSettingsPrewarmShell: View {
    let viewModel: DirectorSessionViewModel
    let mediaViewModel: BroadcastMediaViewModel
    @Bindable var previewMonitor: DirectorPreviewMonitorStore
    @Bindable var intercomService: TeamIntercomService

    @State private var draftVideoQuality: DirectorMonitorQualitySettings
    @State private var draftWidgetConfiguration = BroadcastWidgetConfiguration()
    @State private var draftWidgetDisplayName = "Prewarm"

    init(
        viewModel: DirectorSessionViewModel,
        mediaViewModel: BroadcastMediaViewModel,
        previewMonitor: DirectorPreviewMonitorStore,
        intercomService: TeamIntercomService
    ) {
        self.viewModel = viewModel
        self.mediaViewModel = mediaViewModel
        self.previewMonitor = previewMonitor
        self.intercomService = intercomService
        _draftVideoQuality = State(initialValue: viewModel.monitorQuality)
    }

    var body: some View {
        VStack(spacing: 0) {
            DirectorVideoQualityPanel(settings: $draftVideoQuality)
            PreviewMonitorSettingsForm(
                settings: $previewMonitor.settings,
                onOpenMonitor: {}
            )
            BroadcastWidgetStudioPanel(
                configuration: $draftWidgetConfiguration,
                displayName: $draftWidgetDisplayName,
                templateTitle: draftWidgetConfiguration.resolvedTemplate.title,
                logoURL: nil,
                isEditingExisting: false,
                isEditingPlacement: false,
                onEnterPlayMode: {},
                onEnterLayoutMode: {},
                onImportLogo: {},
                onImportLogoFromPhotoLibrary: {},
                onSave: {},
                onPreview: {},
                onGoLive: {},
                onClose: {}
            )
        }
        .frame(width: 0, height: 0)
        .opacity(0)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
