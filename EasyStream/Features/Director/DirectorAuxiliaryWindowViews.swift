import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport
#if os(macOS)
import AppKit
#endif

#if os(macOS)
struct DirectorStudioSettingsWindowView: View {
    @Bindable private var session = DirectorWorkspaceSession.shared
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Group {
            if let viewModel = session.sessionViewModel,
               let mediaViewModel = session.mediaViewModel,
               let intercomService = session.intercomService,
               let previewMonitor = session.previewMonitor {
                DirectorStudioSettingsHubView(
                    viewModel: viewModel,
                    mediaViewModel: mediaViewModel,
                    previewMonitor: previewMonitor,
                    intercomService: intercomService,
                    initialTab: session.pendingStudioSettingsTab,
                    onOpenPreviewMonitor: {
                        session.onOpenPreviewMonitor?()
                    },
                    onDone: {
                        dismissWindow(id: "director-studio-settings")
                    }
                )
            } else {
                ContentUnavailableView(
                    "Director no activo",
                    systemImage: "video.slash",
                    description: Text("Abre una sesión de director para ver los ajustes.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BroadcastTheme.panelBackground)
            }
        }
    }
}

struct DirectorWidgetStudioWindowView: View {
    @Bindable private var session = DirectorWorkspaceSession.shared
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Group {
            if let mediaViewModel = session.mediaViewModel, mediaViewModel.isWidgetStudioOpen {
                DirectorWidgetStudioEditorView(mediaViewModel: mediaViewModel) {
                    mediaViewModel.closeWidgetStudio()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Cerrar") {
                            mediaViewModel.closeWidgetStudio()
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "Sin widget en edición",
                    systemImage: "wand.and.stars",
                    description: Text("Elige «Nuevo widget» en la biblioteca del director.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BroadcastTheme.panelBackground)
            }
        }
        .background {
            WidgetStudioWindowChrome()
        }
        .onChange(of: session.mediaViewModel?.isWidgetStudioOpen ?? false) { _, isOpen in
            // Dismiss this window only. dismissWindow(id:) from the director closes the director.
            if !isOpen {
                dismissWindow()
            }
        }
        .onDisappear {
            guard session.mediaViewModel?.isWidgetStudioOpen == true else { return }
            session.mediaViewModel?.closeWidgetStudio()
        }
    }
}

/// Keeps a restored Widget Studio window from replacing the director on the next launch.
private struct WidgetStudioWindowChrome: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async { mark(view) }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { mark(nsView) }
    }

    private func mark(_ view: NSView) {
        guard let window = view.window else { return }
        guard window.identifier != DirectorMainWindowRecovery.directorWindowID else { return }
        window.title = "Widget Studio"
        window.isRestorable = false
    }
}

struct DirectorStreamSettingsWindowView: View {
    @Bindable private var session = DirectorWorkspaceSession.shared
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Group {
            if let viewModel = session.sessionViewModel {
                DirectorStreamSettingsWindowContent(
                    viewModel: viewModel,
                    onDone: { dismissWindow(id: "director-stream-settings") }
                )
            } else {
                ContentUnavailableView(
                    "Director no activo",
                    systemImage: "dot.radiowaves.up.forward",
                    description: Text("Abre una sesión de director para configurar la emisión.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BroadcastTheme.panelBackground)
            }
        }
    }
}
#endif
