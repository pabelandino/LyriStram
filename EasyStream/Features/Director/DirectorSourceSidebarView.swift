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
            DirectorSidebarTabPicker(selection: $sidebarTab)

            Group {
                switch sidebarTab {
                case .cameras:
                    camerasContent
                case .library:
                    libraryContent
                case .playlists:
                    playlistsContent
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

    private var libraryContent: some View {
        DeferredBroadcastLibraryPanel(
            selectedKind: $mediaViewModel.selectedLibraryKind,
            resources: mediaViewModel.filteredResources(for: mediaViewModel.selectedLibraryKind),
            playlists: mediaViewModel.playlists,
            selectedPlaylistID: mediaViewModel.selectedPlaylistID(for: mediaViewModel.selectedLibraryKind),
            activeResourceIDs: mediaViewModel.liveWidgetIDs.union(
                mediaViewModel.liveFullScreenGraphicID.map { [$0] } ?? []
            ),
            editingResourceID: mediaViewModel.editingWidgetResource?.id,
            searchText: mediaViewModel.librarySearchText,
            onSearchChange: { mediaViewModel.librarySearchText = $0 },
            onSelectPlaylist: { mediaViewModel.setSelectedPlaylistID($0, for: mediaViewModel.selectedLibraryKind) },
            onImport: { mediaViewModel.beginImport(kind: $0) },
            onCreateWidget: { mediaViewModel.isWidgetTemplatePickerPresented = true },
            onEditWidget: { mediaViewModel.openWidgetStudio(for: $0) },
            onSelectResource: { mediaViewModel.selectResource($0) },
            onTakeToProgram: { mediaViewModel.takeResourceToProgram($0) },
            onRemoveFromProgram: { resource in
                if resource.kind == .widget {
                    mediaViewModel.removeWidgetFromLive(resource.id)
                } else if mediaViewModel.liveFullScreenGraphicID == resource.id {
                    mediaViewModel.removeFullScreenFromLive()
                }
            },
            onDeleteResource: { mediaViewModel.deleteResource($0) },
            onRenameResource: { mediaViewModel.renameResource($0, to: $1) },
            fileURL: { mediaViewModel.fileURL(for: $0) }
        )
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
