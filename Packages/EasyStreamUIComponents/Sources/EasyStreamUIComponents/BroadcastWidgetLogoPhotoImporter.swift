#if os(iOS)
import PhotosUI
import SwiftUI

public struct BroadcastWidgetLogoPhotoImporter: ViewModifier {
    @Binding var isPresented: Bool
    let onImport: (Data) -> Void

    @State private var selection: [PhotosPickerItem] = []

    public func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $isPresented,
                selection: $selection,
                maxSelectionCount: 1,
                matching: .images
            )
            .onChange(of: selection) { _, newValue in
                guard let item = newValue.first else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        onImport(data)
                    }
                    selection = []
                    isPresented = false
                }
            }
    }
}
#endif
