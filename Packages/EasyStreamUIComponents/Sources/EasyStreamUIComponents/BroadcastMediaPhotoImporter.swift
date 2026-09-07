#if os(iOS)
import PhotosUI
import SwiftUI
import EasyStreamCore

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
