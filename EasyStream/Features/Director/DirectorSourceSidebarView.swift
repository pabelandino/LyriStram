import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Sidebar isolated from the switcher column — tab/kind changes stay in this subtree.
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
                    camerasContent
                case .playlists:
                    playlistsContent
                case .library:
                    EmptyView()
                }
            }
            .id(sidebarTab)
        }
    }

    @ViewBuilder
    private var camerasContent: some View {
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

    @ViewBuilder
    private var playlistsContent: some View {
        BroadcastPlaylistPanel(
            playlists: mediaViewModel.playlists,
            allResources: mediaViewModel.allResources,
            activePlaylistID: mediaViewModel.activePlaylistID,
            isPlaying: mediaViewModel.isPlaylistPlaying,
            queueLabel: mediaViewModel.playlistQueueLabel,
            onCreatePlaylist: { mediaViewModel.isPlaylistEditorPresented = true },
            onEditPlaylist: { mediaViewModel.editingPlaylist = $0; mediaViewModel.isPlaylistEditorPresented = true },
            onDeletePlaylist: { mediaViewModel.deletePlaylist($0) },
            onPlayPlaylist: { mediaViewModel.playPlaylist($0) },
            onStopPlayback: { mediaViewModel.stopPlaylistPlayback() },
            onPlayNext: { mediaViewModel.playNextInQueue() }
        )
    }
}
