import SwiftUI
import LvoqStreamCore
import LvoqStreamUIComponents
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
               session.mediaViewModel != nil,
               session.intercomService != nil,
               let previewMonitor = session.previewMonitor {
                DirectorStudioSettingsHubView(
                    viewModel: viewModel,
                    previewMonitor: previewMonitor,
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
                    L10n.Director.inactiveTitle,
                    systemImage: "video.slash",
                    description: Text(L10n.Director.inactiveSettingsBody)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BroadcastTheme.panelBackground)
            }
        }
        .lvoqRefreshOnLanguageChange()
    }
}

struct DirectorWidgetStudioWindowView: View {
    @Bindable private var session = DirectorWorkspaceSession.shared
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Group {
            if let mediaViewModel = session.mediaViewModel {
                widgetStudio(mediaViewModel)
            } else {
                emptyWidgetStudio
            }
        }
        .background {
            WidgetStudioWindowChrome()
        }
        .lvoqRefreshOnLanguageChange()
        .onChange(of: studioIsOpen) { _, isOpen in
            // Dismiss this window only. dismissWindow(id:) from the director closes the director.
            if !isOpen {
                dismissWindow()
            }
        }
    }

    private var studioIsOpen: Bool {
        session.mediaViewModel?.isWidgetStudioOpen ?? false
    }

    /// `@Bindable` keeps this window subscribed to the draft flag.
    /// Reading it through a plain `if let` missed updates, so Nuevo opened the empty state.
    @ViewBuilder
    private func widgetStudio(_ mediaViewModel: BroadcastMediaViewModel) -> some View {
        @Bindable var mediaViewModel = mediaViewModel
        if mediaViewModel.isWidgetStudioOpen {
            DirectorWidgetStudioEditorView(mediaViewModel: mediaViewModel) {
                mediaViewModel.closeWidgetStudio()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                        Button(L10n.Common.close) {
                            mediaViewModel.closeWidgetStudio()
                        }
                }
            }
        } else {
            emptyWidgetStudio
        }
    }

    private var emptyWidgetStudio: some View {
        ContentUnavailableView(
            L10n.Widget.noWidgetEditing,
            systemImage: "wand.and.stars",
            description: Text(L10n.Director.inactiveWidgetBody)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BroadcastTheme.panelBackground)
    }
}

/// Keeps a restored Widget Studio window from replacing the director on the next launch.
private struct WidgetStudioWindowChrome: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        WidgetStudioWindowMarker(frame: .zero)
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? WidgetStudioWindowMarker)?.attach()
    }
}

/// Marks the studio window and ends the draft only when that window actually closes.
/// SwiftUI calls `onDisappear` while rebuilding the scene, which cleared the new widget.
private final class WidgetStudioWindowMarker: NSView {
    private var closeObserver: NSObjectProtocol?
    private let studioID = NSUserInterfaceItemIdentifier("director-widget-studio")

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        attach()
    }

    func attach() {
        guard let window else { return }
        guard window.identifier != DirectorMainWindowRecovery.directorWindowID else { return }
        window.title = BundleLocalization.string("window.widget_studio")
        window.isRestorable = false
        if window.identifier != studioID {
            window.identifier = studioID
        }
        guard closeObserver == nil else { return }
        closeObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { notification in
            let closing = notification.object as? NSWindow
            Task { @MainActor in
                let anotherStudio = NSApp.windows.contains { candidate in
                    candidate !== closing
                        && candidate.isVisible
                        && candidate.identifier?.rawValue == "director-widget-studio"
                }
                guard !anotherStudio else { return }
                guard DirectorWorkspaceSession.shared.mediaViewModel?.isWidgetStudioOpen == true else { return }
                DirectorWorkspaceSession.shared.mediaViewModel?.closeWidgetStudio()
            }
        }
    }

    deinit {
        if let closeObserver {
            NotificationCenter.default.removeObserver(closeObserver)
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
                    L10n.Director.inactiveTitle,
                    systemImage: "dot.radiowaves.up.forward",
                    description: Text(L10n.Director.inactiveStreamBody)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BroadcastTheme.panelBackground)
            }
        }
        .lvoqRefreshOnLanguageChange()
    }
}
#endif
