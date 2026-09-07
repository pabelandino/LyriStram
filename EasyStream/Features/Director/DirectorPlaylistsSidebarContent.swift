import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorPlaylistsSidebarContent: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel

    var body: some View {
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
}
