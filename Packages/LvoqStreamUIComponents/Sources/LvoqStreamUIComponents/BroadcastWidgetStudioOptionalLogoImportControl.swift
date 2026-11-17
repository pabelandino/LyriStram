import SwiftUI
import LvoqStreamCore

struct BroadcastWidgetStudioOptionalLogoImportControl: View {
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
            Label(BundleLocalization.string("logo.optional"), systemImage: "photo")
        }
        .buttonStyle(.bordered)
#else
        Button(action: onImportLogo) {
            Label(BundleLocalization.string("logo.optional_png"), systemImage: "photo")
        }
        .buttonStyle(.bordered)
#endif
    }
}
