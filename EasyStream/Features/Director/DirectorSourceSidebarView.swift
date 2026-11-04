import SwiftUI
import EasyStreamUIComponents

struct DirectorSourceSidebarView: View {
    let viewModel: DirectorSessionViewModel

    var body: some View {
        DirectorSourcesPanel(title: DirectorSidebarTab.cameras.title) {
            DirectorCamerasSidebarContent(viewModel: viewModel)
        }
    }
}
