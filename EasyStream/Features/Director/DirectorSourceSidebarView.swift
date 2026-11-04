import SwiftUI
import EasyStreamUIComponents

struct DirectorSourceSidebarView: View {
    let viewModel: DirectorSessionViewModel
    var onBack: (() -> Void)?
    var onOpenSettings: (() -> Void)?
    var onOpenMonitor: (() -> Void)?

    var body: some View {
        DirectorSourcesPanel(
            title: DirectorSidebarTab.cameras.title,
            onBack: onBack,
            onOpenSettings: onOpenSettings,
            onOpenMonitor: onOpenMonitor
        ) {
            DirectorCamerasSidebarContent(viewModel: viewModel)
        }
    }
}
