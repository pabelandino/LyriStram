import SwiftUI
import EasyStreamCore

public struct BroadcastMediaLibraryPanel: View {
    @Binding var selectedKind: BroadcastResourceKind
    let resources: [BroadcastResource]
    let playlists: [BroadcastPlaylist]
    let selectedPlaylistID: UUID?
    let activeResourceIDs: Set<UUID>
    let editingResourceID: UUID?
    let searchText: String
    let onSearchChange: (String) -> Void
    let onSelectPlaylist: (UUID?) -> Void
    let onImport: (BroadcastResourceKind) -> Void
    let onCreateWidget: () -> Void
    let onEditWidget: (BroadcastResource) -> Void
    let onSelectResource: (BroadcastResource) -> Void
    let onTakeToProgram: (BroadcastResource) -> Void
    let onRemoveFromProgram: (BroadcastResource) -> Void
    let onDeleteResource: (BroadcastResource) -> Void
    let onRenameResource: (BroadcastResource, String) -> Void
    let fileURL: (BroadcastResource) -> URL

    @State private var assetPendingRename: BroadcastResource?
    @State private var renameDraft = ""

    public init(
        selectedKind: Binding<BroadcastResourceKind>,
        resources: [BroadcastResource],
        playlists: [BroadcastPlaylist],
        selectedPlaylistID: UUID?,
        activeResourceIDs: Set<UUID>,
        editingResourceID: UUID?,
        searchText: String,
        onSearchChange: @escaping (String) -> Void,
        onSelectPlaylist: @escaping (UUID?) -> Void,
        onImport: @escaping (BroadcastResourceKind) -> Void,
        onCreateWidget: @escaping () -> Void,
        onEditWidget: @escaping (BroadcastResource) -> Void,
        onSelectResource: @escaping (BroadcastResource) -> Void,
        onTakeToProgram: @escaping (BroadcastResource) -> Void,
        onRemoveFromProgram: @escaping (BroadcastResource) -> Void,
        onDeleteResource: @escaping (BroadcastResource) -> Void,
        onRenameResource: @escaping (BroadcastResource, String) -> Void,
        fileURL: @escaping (BroadcastResource) -> URL
    ) {
        self._selectedKind = selectedKind
        self.resources = resources
        self.playlists = playlists
        self.selectedPlaylistID = selectedPlaylistID
        self.activeResourceIDs = activeResourceIDs
        self.editingResourceID = editingResourceID
        self.searchText = searchText
        self.onSearchChange = onSearchChange
        self.onSelectPlaylist = onSelectPlaylist
        self.onImport = onImport
        self.onCreateWidget = onCreateWidget
        self.onEditWidget = onEditWidget
        self.onSelectResource = onSelectResource
        self.onTakeToProgram = onTakeToProgram
        self.onRemoveFromProgram = onRemoveFromProgram
        self.onDeleteResource = onDeleteResource
        self.onRenameResource = onRenameResource
        self.fileURL = fileURL
    }

    private var filteredPlaylists: [BroadcastPlaylist] {
        playlists.filter { playlist in
            switch selectedKind {
            case .image: playlist.kind == .image || playlist.kind == .mixed
            case .video: playlist.kind == .video || playlist.kind == .mixed
            case .widget: playlist.kind == .widget || playlist.kind == .mixed
            }
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Tipo", selection: $selectedKind) {
                ForEach(BroadcastResourceKind.allCases, id: \.self) { kind in
                    Text(kind.title).tag(kind)
                }
            }
            .broadcastNativeSegmentedControl()

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(BroadcastTheme.subtleText)
                TextField("Buscar", text: Binding(
                    get: { searchText },
                    set: onSearchChange
                ))
                .textFieldStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(BroadcastTheme.panelElevated, in: RoundedRectangle(cornerRadius: 8))

            HStack {
                Menu {
                    Button("Importar \(selectedKind.title.lowercased())") {
                        onImport(selectedKind)
                    }
                    if selectedKind == .widget {
                        Button("Nuevo widget") { onCreateWidget() }
                    }
                } label: {
                    Label("Agregar", systemImage: "plus")
                        .font(.caption.weight(.semibold))
                }
                .menuStyle(.borderlessButton)

                Spacer()

                Menu {
                    Button("Todas") { onSelectPlaylist(nil) }
                    ForEach(filteredPlaylists) { playlist in
                        Button(playlist.name) { onSelectPlaylist(playlist.id) }
                    }
                } label: {
                    Label(
                        selectedPlaylistID.flatMap { id in filteredPlaylists.first(where: { $0.id == id })?.name } ?? "Playlist",
                        systemImage: "line.3.horizontal.decrease.circle"
                    )
                    .font(.caption)
                }
                .menuStyle(.borderlessButton)
            }

            if resources.isEmpty {
                BroadcastInspectorEmptyState("Sin recursos", systemImage: selectedKind.systemImage)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                LazyVStack(spacing: 6) {
                    ForEach(resources) { resource in
                        BroadcastResourceRow(
                            resource: resource,
                            fileURL: fileURL(resource),
                            isActive: activeResourceIDs.contains(resource.id) || editingResourceID == resource.id,
                            isLiveOnAir: activeResourceIDs.contains(resource.id),
                            onSelect: { onSelectResource(resource) },
                            onEdit: resource.kind == .widget ? { onEditWidget(resource) } : nil,
                            onTakeToProgram: { onTakeToProgram(resource) },
                            onRemoveFromProgram: activeResourceIDs.contains(resource.id)
                                ? { onRemoveFromProgram(resource) }
                                : nil,
                            onRename: {
                                renameDraft = resource.listLabel
                                assetPendingRename = resource
                            },
                            onDelete: { onDeleteResource(resource) }
                        )
                    }
                }
            }
        }
        .alert("Renombrar", isPresented: Binding(
            get: { assetPendingRename != nil },
            set: { if !$0 { assetPendingRename = nil } }
        )) {
            TextField("Nombre", text: $renameDraft)
            Button("Cancelar", role: .cancel) { assetPendingRename = nil }
            Button("Guardar") {
                if let asset = assetPendingRename {
                    onRenameResource(asset, renameDraft)
                }
                assetPendingRename = nil
            }
        }
    }
}
