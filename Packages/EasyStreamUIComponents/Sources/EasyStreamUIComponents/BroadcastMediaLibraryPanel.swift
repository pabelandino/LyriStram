import SwiftUI
import EasyStreamCore

public struct BroadcastMediaLibraryPanel: View {
    @Binding var selectedKind: BroadcastResourceKind
    let imageResources: [BroadcastResource]
    let videoResources: [BroadcastResource]
    let widgetResources: [BroadcastResource]
    let activeResourceIDs: Set<UUID>
    let lyrioraResourceIDs: Set<UUID>
    let editingResourceID: UUID?
    let searchText: String
    let onSearchChange: (String) -> Void
    let onImport: (BroadcastResourceKind) -> Void
    let onCreateWidget: () -> Void
    let onEditWidget: (BroadcastResource) -> Void
    let onSelectResource: (BroadcastResource) -> Void
    let onTakeToProgram: (BroadcastResource) -> Void
    let onRemoveFromProgram: (BroadcastResource) -> Void
    let fileURL: (BroadcastResource) -> URL

    public init(
        selectedKind: Binding<BroadcastResourceKind>,
        imageResources: [BroadcastResource],
        videoResources: [BroadcastResource],
        widgetResources: [BroadcastResource],
        activeResourceIDs: Set<UUID>,
        lyrioraResourceIDs: Set<UUID> = [],
        editingResourceID: UUID?,
        searchText: String,
        onSearchChange: @escaping (String) -> Void,
        onImport: @escaping (BroadcastResourceKind) -> Void,
        onCreateWidget: @escaping () -> Void,
        onEditWidget: @escaping (BroadcastResource) -> Void,
        onSelectResource: @escaping (BroadcastResource) -> Void,
        onTakeToProgram: @escaping (BroadcastResource) -> Void,
        onRemoveFromProgram: @escaping (BroadcastResource) -> Void,
        fileURL: @escaping (BroadcastResource) -> URL
    ) {
        self._selectedKind = selectedKind
        self.imageResources = imageResources
        self.videoResources = videoResources
        self.widgetResources = widgetResources
        self.activeResourceIDs = activeResourceIDs
        self.lyrioraResourceIDs = lyrioraResourceIDs
        self.editingResourceID = editingResourceID
        self.searchText = searchText
        self.onSearchChange = onSearchChange
        self.onImport = onImport
        self.onCreateWidget = onCreateWidget
        self.onEditWidget = onEditWidget
        self.onSelectResource = onSelectResource
        self.onTakeToProgram = onTakeToProgram
        self.onRemoveFromProgram = onRemoveFromProgram
        self.fileURL = fileURL
    }

    @State private var warmedKinds: Set<BroadcastResourceKind> = []

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

            HStack(spacing: 8) {
                Button {
                    onImport(selectedKind)
                } label: {
                    Label("Agregar", systemImage: "plus")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.borderless)

                if selectedKind == .widget {
                    Button(action: onCreateWidget) {
                        Label("Nuevo", systemImage: "rectangle.3.group")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.borderless)
                }
            }

            ZStack(alignment: .topLeading) {
                ForEach(BroadcastResourceKind.allCases, id: \.self) { kind in
                    if warmedKinds.contains(kind) {
                        resourceList(for: kind)
                            .opacity(selectedKind == kind ? 1 : 0)
                            .allowsHitTesting(selectedKind == kind)
                            .accessibilityHidden(selectedKind != kind)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .task {
            for kind in BroadcastResourceKind.allCases {
                warmedKinds.insert(kind)
                await Task.yield()
            }
        }
    }

    private func resources(for kind: BroadcastResourceKind) -> [BroadcastResource] {
        switch kind {
        case .image: imageResources
        case .video: videoResources
        case .widget: widgetResources
        }
    }

    @ViewBuilder
    private func resourceList(for kind: BroadcastResourceKind) -> some View {
        let resources = resources(for: kind)
        if resources.isEmpty {
            BroadcastInspectorEmptyState("Sin recursos", systemImage: kind.systemImage)
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
                        showsLyrioraActivity: lyrioraResourceIDs.contains(resource.id),
                        onSelect: { onSelectResource(resource) },
                        onEdit: resource.kind == .widget ? { onEditWidget(resource) } : nil,
                        onTakeToProgram: { onTakeToProgram(resource) },
                        onRemoveFromProgram: activeResourceIDs.contains(resource.id)
                            ? { onRemoveFromProgram(resource) }
                            : nil
                    )
                }
            }
        }
    }
}
