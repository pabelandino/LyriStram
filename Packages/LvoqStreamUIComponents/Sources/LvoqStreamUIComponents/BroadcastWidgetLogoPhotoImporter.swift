#if os(iOS)
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

/// Loads photo-library images (JPEG/HEIC/PNG) for widget logo import.
struct WidgetLogoImageImport: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            WidgetLogoImageImport(data: data)
        }
        DataRepresentation(importedContentType: .png) { data in
            WidgetLogoImageImport(data: data)
        }
        DataRepresentation(importedContentType: .jpeg) { data in
            WidgetLogoImageImport(data: data)
        }
        DataRepresentation(importedContentType: .heic) { data in
            WidgetLogoImageImport(data: data)
        }
    }
}

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
                Task { @MainActor in
                    defer {
                        selection = []
                        isPresented = false
                    }
                    guard let imported = try? await item.loadTransferable(type: WidgetLogoImageImport.self) else {
                        return
                    }
                    onImport(imported.data)
                }
            }
    }
}
#endif
