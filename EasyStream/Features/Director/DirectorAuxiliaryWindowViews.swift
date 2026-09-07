import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

#if os(macOS)
struct DirectorSettingsWindowView: View {
    @Bindable private var session = DirectorWorkspaceSession.shared
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Group {
            if let viewModel = session.sessionViewModel,
               let mediaViewModel = session.mediaViewModel,
               let intercomService = session.intercomService,
               let previewMonitor = session.previewMonitor {
                DirectorSettingsSheet(
                    viewModel: viewModel,
                    mediaViewModel: mediaViewModel,
                    previewMonitor: previewMonitor,
                    intercomService: intercomService,
                    onOpenPreviewMonitor: {
                        session.onOpenPreviewMonitor?()
                    },
                    onConfigurePreviewMonitor: {
                        session.onConfigurePreviewMonitor?()
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

struct DirectorPreviewMonitorSettingsWindowView: View {
    @Bindable private var session = DirectorWorkspaceSession.shared

    var body: some View {
        Group {
            if let previewMonitor = session.previewMonitor {
                DirectorPreviewMonitorSettingsWindowContent(
                    previewMonitor: previewMonitor,
                    onOpenMonitor: { session.onOpenPreviewMonitor?() }
                )
            } else {
                ContentUnavailableView(
                    "Director no activo",
                    systemImage: "display.2",
                    description: Text("Abre una sesión de director para configurar el monitor.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BroadcastTheme.panelBackground)
            }
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
