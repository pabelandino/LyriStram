import SwiftUI
import EasyStreamCore

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
