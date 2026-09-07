import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorSourceSidebarView: View {
    @Binding var sidebarTab: DirectorSidebarTab
    let viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel

    var body: some View {
        DirectorSourcesPanel(title: sidebarTab.title) {
            DirectorLeftSidebarTabPicker(selection: $sidebarTab)

            Group {
                switch sidebarTab {
                case .cameras:
                    DirectorCamerasSidebarContent(viewModel: viewModel)
                case .playlists:
                    DirectorPlaylistsSidebarContent(mediaViewModel: mediaViewModel)
                case .library:
                    EmptyView()
                }
            }
            .id(sidebarTab)
        }
    }
}
