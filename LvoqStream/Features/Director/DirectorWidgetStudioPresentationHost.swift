import LvoqStreamCore
import SwiftUI
import UniformTypeIdentifiers
import LvoqStreamUIComponents

/// Routes widget studio to a dedicated window (macOS) or full-screen cover (iOS).
struct DirectorWidgetStudioPresentationHost: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel

#if os(macOS)
    @Environment(\.openWindow) private var openWindow
#endif

    var body: some View {
#if os(macOS)
        Color.clear
            .frame(width: 0, height: 0)
            .onChange(of: mediaViewModel.isWidgetStudioOpen) { _, isOpen in
                guard isOpen, let token = WidgetStudioWindowToken.value else { return }
                DirectorModalPresentation.afterYield {
                    openWindow(id: "director-widget-studio", value: token)
                }
            }
#else
        Color.clear
            .frame(width: 0, height: 0)
            .fullScreenCover(
                isPresented: .init(
                    get: { mediaViewModel.isWidgetStudioOpen },
                    set: { isPresented in
                        if !isPresented { mediaViewModel.closeWidgetStudio() }
                    }
                )
            ) {
                NavigationStack {
                    DirectorWidgetStudioEditorView(mediaViewModel: mediaViewModel) {
                        mediaViewModel.closeWidgetStudio()
                    }
                    .navigationTitle(L10n.Widget.studioTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(BundleLocalization.string("Cerrar")) { mediaViewModel.closeWidgetStudio() }
                        }
                    }
                }
                .fileImporter(
                    isPresented: $mediaViewModel.isWidgetLogoImporterPresented,
                    allowedContentTypes: [.png, .jpeg, .heic, .image],
                    allowsMultipleSelection: false
                ) { result in
                    guard case .success(let urls) = result, let url = urls.first else { return }
                    mediaViewModel.importWidgetLogo(from: url)
                }
                .broadcastWidgetLogoPhotoImporter(
                    isPresented: $mediaViewModel.isWidgetLogoPhotoPickerPresented,
                    onImport: { mediaViewModel.importWidgetLogoData($0) }
                )
            }
#endif
    }
}

#if os(macOS)
extension DirectorSessionView {
    func platformOpenWidgetStudioWindow() {
        let token = WidgetStudioWindowToken.prepare()
        DirectorModalPresentation.afterYield {
            openWindow(id: "director-widget-studio", value: token)
        }
    }
}
#else
extension DirectorSessionView {
    func platformOpenWidgetStudioWindow() {}
}
#endif
