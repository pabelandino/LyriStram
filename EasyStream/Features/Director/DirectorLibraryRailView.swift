import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Right rail — media library for quick drag/take to program.
struct DirectorLibraryRailView: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel

    var body: some View {
        DirectorLibraryRailPanel {
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
                onSelectPlaylist: {
                    mediaViewModel.setSelectedPlaylistID($0, for: mediaViewModel.selectedLibraryKind)
                },
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
    }
}
