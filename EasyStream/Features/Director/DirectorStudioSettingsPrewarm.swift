import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Mounts heavy settings panels off-screen once so the first user-open does not stall PROG Metal.
struct DirectorStudioSettingsPrewarmShell: View {
    @Bindable var viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    @Bindable var previewMonitor: DirectorPreviewMonitorStore
    @Bindable var intercomService: TeamIntercomService

    @State private var draftVideoQuality: DirectorMonitorQualitySettings

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
            DirectorSettingsStudioTab(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                intercomService: intercomService
            )
            DirectorVideoQualityPanel(settings: $draftVideoQuality)
            PreviewMonitorSettingsForm(
                settings: $previewMonitor.settings,
                onOpenMonitor: {}
            )
        }
        .frame(width: 0, height: 0)
        .opacity(0)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
