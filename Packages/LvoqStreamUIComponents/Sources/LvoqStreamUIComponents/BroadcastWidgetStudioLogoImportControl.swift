import SwiftUI
import LvoqStreamCore

struct BroadcastWidgetStudioLogoImportControl: View {
    let logoURL: URL?
    let onImportLogo: () -> Void
    let onImportLogoFromPhotoLibrary: () -> Void

    var body: some View {
#if os(iOS)
        Menu {
            Button(action: onImportLogoFromPhotoLibrary) {
                Label(BundleLocalization.string("photo.library"), systemImage: "photo.on.rectangle")
            }
            Button(action: onImportLogo) {
                Label(BundleLocalization.string("common.files"), systemImage: "folder")
            }
        } label: {
            Label(logoURL == nil ? "Importar logo" : "Cambiar logo", systemImage: "photo.badge.plus")
        }
        .buttonStyle(.bordered)
#else
        Button(action: onImportLogo) {
            Label(logoURL == nil ? "Importar logo PNG" : "Cambiar logo PNG", systemImage: "photo.badge.plus")
        }
        .buttonStyle(.bordered)
#endif
    }
}
