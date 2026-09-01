import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import EasyStreamCore
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if canImport(UIKit)
import UIKit
#endif

public enum DirectorSidebarTab: String, CaseIterable, Identifiable {
    case cameras
    case library
    case playlists

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .cameras: "Cámaras"
        case .library: "Biblioteca"
        case .playlists: "Playlists"
        }
    }

    public var systemImage: String {
        switch self {
        case .cameras: "video.fill"
        case .library: "photo.on.rectangle.angled"
        case .playlists: "list.bullet.rectangle"
        }
    }
}

public struct DirectorSidebarTabPicker: View {
    @Binding var selection: DirectorSidebarTab

    public init(selection: Binding<DirectorSidebarTab>) {
        self._selection = selection
    }

    public var body: some View {
        Picker("Panel", selection: $selection) {
            ForEach(DirectorSidebarTab.allCases) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .broadcastNativeSegmentedControl()
        .padding(.bottom, 4)
    }
}

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

public struct BroadcastResourceRow: View {
    let resource: BroadcastResource
    let fileURL: URL
    let isActive: Bool
    let isLiveOnAir: Bool
    let onSelect: () -> Void
    let onEdit: (() -> Void)?
    let onTakeToProgram: () -> Void
    let onRemoveFromProgram: (() -> Void)?
    let onRename: () -> Void
    let onDelete: () -> Void

    public init(
        resource: BroadcastResource,
        fileURL: URL,
        isActive: Bool,
        isLiveOnAir: Bool = false,
        onSelect: @escaping () -> Void,
        onEdit: (() -> Void)?,
        onTakeToProgram: @escaping () -> Void,
        onRemoveFromProgram: (() -> Void)? = nil,
        onRename: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.resource = resource
        self.fileURL = fileURL
        self.isActive = isActive
        self.isLiveOnAir = isLiveOnAir
        self.onSelect = onSelect
        self.onEdit = onEdit
        self.onTakeToProgram = onTakeToProgram
        self.onRemoveFromProgram = onRemoveFromProgram
        self.onRename = onRename
        self.onDelete = onDelete
    }

    public var body: some View {
        HStack(spacing: 8) {
            BroadcastResourceThumbnail(resource: resource, fileURL: fileURL)
                .frame(width: 44, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 5))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(resource.listLabel)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                        .truncationMode(.tail)

                    if isLiveOnAir {
                        BroadcastCompactLiveBadge()
                    }
                }

                Text(resource.kind.title)
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .lineLimit(1)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            Menu {
                Button("Seleccionar") { onSelect() }
                if let onEdit {
                    Button("Editar en Studio") { onEdit() }
                }
                if isLiveOnAir, let onRemoveFromProgram {
                    Button("Quitar del aire", role: .destructive) { onRemoveFromProgram() }
                } else {
                    Button("Al aire") { onTakeToProgram() }
                }
                Button("Renombrar") { onRename() }
                Divider()
                Button("Eliminar", role: .destructive) { onDelete() }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            isActive ? BroadcastTheme.programRed.opacity(0.12) : BroadcastTheme.panelElevated,
            in: RoundedRectangle(cornerRadius: 8)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
}

private struct BroadcastResourceThumbnail: View {
    let resource: BroadcastResource
    let fileURL: URL

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(BroadcastTheme.panelBackground)
            switch resource.kind {
            case .image:
                BroadcastAsyncThumbnailImage(url: fileURL)
            case .video:
                Image(systemName: "film")
                    .foregroundStyle(BroadcastTheme.subtleText)
            case .widget:
                Image(systemName: "rectangle.3.group")
                    .foregroundStyle(BroadcastTheme.audioGold)
            }
        }
        .clipped()
    }
}

/// Loads library thumbnails off the main thread with downscaled ImageIO decode + cache.
private struct BroadcastAsyncThumbnailImage: View {
    let url: URL
    @State private var image: Image?

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .task(id: url) {
            if let cached = BroadcastMediaThumbnailLoader.cachedImage(for: url) {
                image = cached
                return
            }
            image = await BroadcastMediaThumbnailLoader.loadThumbnail(from: url)
        }
    }
}

public struct BroadcastPlaylistPanel: View {
    let playlists: [BroadcastPlaylist]
    let allResources: [BroadcastResource]
    let activePlaylistID: UUID?
    let isPlaying: Bool
    let queueLabel: String?
    let onCreatePlaylist: () -> Void
    let onEditPlaylist: (BroadcastPlaylist) -> Void
    let onDeletePlaylist: (BroadcastPlaylist) -> Void
    let onPlayPlaylist: (BroadcastPlaylist) -> Void
    let onStopPlayback: () -> Void
    let onPlayNext: () -> Void

    public init(
        playlists: [BroadcastPlaylist],
        allResources: [BroadcastResource],
        activePlaylistID: UUID?,
        isPlaying: Bool,
        queueLabel: String?,
        onCreatePlaylist: @escaping () -> Void,
        onEditPlaylist: @escaping (BroadcastPlaylist) -> Void,
        onDeletePlaylist: @escaping (BroadcastPlaylist) -> Void,
        onPlayPlaylist: @escaping (BroadcastPlaylist) -> Void,
        onStopPlayback: @escaping () -> Void,
        onPlayNext: @escaping () -> Void
    ) {
        self.playlists = playlists
        self.allResources = allResources
        self.activePlaylistID = activePlaylistID
        self.isPlaying = isPlaying
        self.queueLabel = queueLabel
        self.onCreatePlaylist = onCreatePlaylist
        self.onEditPlaylist = onEditPlaylist
        self.onDeletePlaylist = onDeletePlaylist
        self.onPlayPlaylist = onPlayPlaylist
        self.onStopPlayback = onStopPlayback
        self.onPlayNext = onPlayNext
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Playlists para transmisión")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button(action: onCreatePlaylist) {
                    Label("Nueva", systemImage: "plus")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.borderless)
            }

            if isPlaying {
                VStack(alignment: .leading, spacing: 8) {
                    if let queueLabel {
                        Text("Reproduciendo: \(queueLabel)")
                            .font(.caption)
                            .foregroundStyle(BroadcastTheme.subtleText)
                    }
                    HStack {
                        Button("Siguiente", action: onPlayNext)
                        Button("Detener", role: .destructive, action: onStopPlayback)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(10)
                .broadcastPanel()
            }

            if playlists.isEmpty {
                BroadcastInspectorEmptyState("Sin playlists", systemImage: "list.bullet.rectangle")
                    .padding(.vertical, 20)
            } else {
                ForEach(playlists) { playlist in
                    BroadcastPlaylistRow(
                        playlist: playlist,
                        itemCount: resolvedItems(for: playlist).count,
                        isActive: playlist.id == activePlaylistID,
                        onPlay: { onPlayPlaylist(playlist) },
                        onEdit: { onEditPlaylist(playlist) },
                        onDelete: { onDeletePlaylist(playlist) }
                    )
                }
            }
        }
    }

    private func resolvedItems(for playlist: BroadcastPlaylist) -> [BroadcastResource] {
        playlist.itemIDs.compactMap { id in allResources.first { $0.id == id } }
    }
}

private struct BroadcastPlaylistRow: View {
    let playlist: BroadcastPlaylist
    let itemCount: Int
    let isActive: Bool
    let onPlay: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: playlist.kind.systemImage)
                .foregroundStyle(BroadcastTheme.studioAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text(playlist.name)
                    .font(.subheadline.weight(.medium))
                Text("\(itemCount) elemento(s) · \(playlist.kind.title)")
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
            Spacer()
            Button(action: onPlay) {
                Image(systemName: "play.fill")
            }
            .buttonStyle(.borderless)
            Menu {
                Button("Editar", action: onEdit)
                Button("Eliminar", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
        }
        .padding(10)
        .background(
            isActive ? BroadcastTheme.audioGold.opacity(0.12) : BroadcastTheme.panelElevated,
            in: RoundedRectangle(cornerRadius: 8)
        )
    }
}

public struct BroadcastPlaylistEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State var name: String
    @State var kind: BroadcastPlaylistKind
    @State var itemIDs: [UUID]
    let allResources: [BroadcastResource]
    let onSave: (String, BroadcastPlaylistKind, [UUID]) -> Void

    public init(
        name: String,
        kind: BroadcastPlaylistKind,
        itemIDs: [UUID],
        allResources: [BroadcastResource],
        onSave: @escaping (String, BroadcastPlaylistKind, [UUID]) -> Void
    ) {
        _name = State(initialValue: name)
        _kind = State(initialValue: kind)
        _itemIDs = State(initialValue: itemIDs)
        self.allResources = allResources
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Playlist") {
                    TextField("Nombre", text: $name)
                    Picker("Tipo", selection: $kind) {
                        ForEach(BroadcastPlaylistKind.allCases, id: \.self) { kind in
                            Text(kind.title).tag(kind)
                        }
                    }
                }

                Section("Elementos") {
                    ForEach(allResources) { resource in
                        Toggle(resource.listLabel, isOn: Binding(
                            get: { itemIDs.contains(resource.id) },
                            set: { isOn in
                                if isOn {
                                    if !itemIDs.contains(resource.id) {
                                        itemIDs.append(resource.id)
                                    }
                                } else {
                                    itemIDs.removeAll { $0 == resource.id }
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Editar playlist")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(name, kind, itemIDs)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 420, minHeight: 480)
#endif
    }
}

#if os(iOS)
public struct BroadcastMediaPhotoImporter: ViewModifier {
    @Binding var isPresented: Bool
    let kind: BroadcastResourceKind
    let onImport: (Data, String) -> Void

    @State private var selection: [PhotosPickerItem] = []

    public func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $isPresented,
                selection: $selection,
                maxSelectionCount: 1,
                matching: kind == .image ? .images : .videos
            )
            .onChange(of: selection) { _, newValue in
                guard let item = newValue.first else { return }
                Task {
                    if kind == .image, let data = try? await item.loadTransferable(type: Data.self) {
                        onImport(data, "jpg")
                    } else if let data = try? await item.loadTransferable(type: Data.self) {
                        onImport(data, "mp4")
                    }
                    selection = []
                    isPresented = false
                }
            }
    }
}
#endif

public extension View {
#if os(iOS)
    func broadcastMediaPhotoImporter(
        isPresented: Binding<Bool>,
        kind: BroadcastResourceKind,
        onImport: @escaping (Data, String) -> Void
    ) -> some View {
        modifier(BroadcastMediaPhotoImporter(isPresented: isPresented, kind: kind, onImport: onImport))
    }
#endif
}
