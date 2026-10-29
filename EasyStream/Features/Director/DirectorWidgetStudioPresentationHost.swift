import SwiftUI
import UniformTypeIdentifiers
import EasyStreamUIComponents

/// Routes widget studio to a dedicated window (macOS) or full-screen cover (iOS).
struct DirectorWidgetStudioPresentationHost: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel

#if os(macOS)
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
#endif

    var body: some View {
#if os(macOS)
        Color.clear
            .frame(width: 0, height: 0)
            .onChange(of: mediaViewModel.isWidgetStudioOpen) { _, isOpen in
                if isOpen {
                    DirectorModalPresentation.afterYield {
                        openWindow(id: "director-widget-studio")
                    }
                } else {
                    dismissWindow(id: "director-widget-studio")
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
                    .navigationTitle("Widget Studio")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Cerrar") { mediaViewModel.closeWidgetStudio() }
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
        DirectorModalPresentation.afterYield {
            openWindow(id: "director-widget-studio")
        }
    }

    func platformPrewarmWidgetStudioWindowIfNeeded() {
        guard !DirectorWorkspaceSession.shared.hasPrewarmedWidgetStudioUI else { return }
        guard !programOutputStore.isWindowOpen, !viewModel.isPublishing else { return }

        openWindow(id: "director-widget-studio")
        Task { @MainActor in
            await DirectorModalPresentation.deferHeavyUI()
            await DirectorModalPresentation.deferHeavyUI()
            dismissWindow(id: "director-widget-studio")
            DirectorWorkspaceSession.shared.markWidgetStudioUIPrewarmed()
        }
    }
}
#else
extension DirectorSessionView {
    func platformOpenWidgetStudioWindow() {}

    func platformPrewarmWidgetStudioWindowIfNeeded() {}
}
#endif
