import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Right rail — library on top, audio and camera controls below.
struct DirectorLibraryRailView: View {
    @Bindable var viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    @Bindable var intercomService: TeamIntercomService
    let onCreateWidget: () -> Void

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                libraryHalf
                    .frame(height: proxy.size.height / 2)
                Divider().overlay(BroadcastTheme.workspaceDivider)
                DirectorRailHandySettingsView(
                    viewModel: viewModel,
                    mediaViewModel: mediaViewModel,
                    intercomService: intercomService
                )
                .frame(height: max(0, proxy.size.height / 2 - 1))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BroadcastTheme.panelBackground)
    }

    private var libraryHalf: some View {
        DirectorLibraryRailPanel {
            DeferredBroadcastLibraryPanel(
                selectedKind: $mediaViewModel.selectedLibraryKind,
                imageResources: mediaViewModel.filteredResources(for: .image),
                videoResources: mediaViewModel.filteredResources(for: .video),
                widgetResources: mediaViewModel.filteredResources(for: .widget),
                activeResourceIDs: mediaViewModel.liveWidgetIDs.union(
                    mediaViewModel.liveFullScreenGraphicID.map { [$0] } ?? []
                ),
                lyrioraResourceIDs: lyrioraResourceIDs,
                editingResourceID: mediaViewModel.editingWidgetResource?.id,
                searchText: mediaViewModel.librarySearchText,
                onSearchChange: { mediaViewModel.librarySearchText = $0 },
                onImport: { mediaViewModel.beginImport(kind: $0) },
                onCreateWidget: onCreateWidget,
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
                fileURL: { mediaViewModel.fileURL(for: $0) }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var lyrioraResourceIDs: Set<UUID> {
        Set(mediaViewModel.widgetResources.compactMap { resource in
            mediaViewModel.loadedConfiguration(for: resource)?.resolvedTemplate == .lyriora ? resource.id : nil
        })
    }
}
