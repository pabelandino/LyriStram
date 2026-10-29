import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

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
    private var session = DirectorWorkspaceSession.shared
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Group {
            if let mediaViewModel = session.mediaViewModel, mediaViewModel.isWidgetStudioOpen {
                DirectorWidgetStudioEditorView(mediaViewModel: mediaViewModel) {
                    mediaViewModel.closeWidgetStudio()
                    dismissWindow(id: "director-widget-studio")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Cerrar") {
                            mediaViewModel.closeWidgetStudio()
                            dismissWindow(id: "director-widget-studio")
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
        .onDisappear {
            guard session.mediaViewModel?.isWidgetStudioOpen == true else { return }
            session.mediaViewModel?.closeWidgetStudio()
        }
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
