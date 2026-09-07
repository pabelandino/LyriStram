import SwiftUI

struct BroadcastWidgetStudioOptionalLogoImportControl: View {
    let onImportLogo: () -> Void
    let onImportLogoFromPhotoLibrary: () -> Void

    var body: some View {
#if os(iOS)
        Menu {
            Button(action: onImportLogoFromPhotoLibrary) {
                Label("Biblioteca de fotos", systemImage: "photo.on.rectangle")
            }
            Button(action: onImportLogo) {
                Label("Archivos", systemImage: "folder")
            }
        } label: {
            Label("Logo (opcional)", systemImage: "photo")
        }
        .buttonStyle(.bordered)
#else
        Button(action: onImportLogo) {
            Label("Logo PNG (opcional)", systemImage: "photo")
        }
        .buttonStyle(.bordered)
#endif
    }
}
