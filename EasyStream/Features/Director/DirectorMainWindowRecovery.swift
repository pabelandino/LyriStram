#if os(macOS)
import AppKit

/// Brings the director window back when macOS restores only Widget Studio.
///
/// The launch prewarm used `dismissWindow`, which closes the key window. That
/// key window is the director (menus, cameras, program). Widget Studio stayed
/// open, and the next launch restored that saved state.
@MainActor
enum DirectorMainWindowRecovery {
    static let directorWindowID = NSUserInterfaceItemIdentifier("director-main")

    private static let auxiliaryTitles: Set<String> = [
        "Widget Studio",
        "Ajustes del estudio",
        "Monitor multiview",
        "Destino RTMPS"
    ]

    private static var didRequestNewWindow = false

    static func schedule() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            recover()
            guard visibleDirectorWindow() == nil else { return }
            try? await Task.sleep(nanoseconds: 500_000_000)
            recover()
        }
    }

    static func recover() {
        if let director = visibleDirectorWindow() {
            director.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let editingWidget = DirectorWorkspaceSession.shared.mediaViewModel?.isWidgetStudioOpen == true
        if !editingWidget {
            closeWindows(titled: "Widget Studio")
        }
        closeWindows(titled: "Ajustes del estudio")
        guard !didRequestNewWindow else { return }
        didRequestNewWindow = true
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("newWindow:")), to: nil, from: nil)
    }

    static func closeWindows(titled title: String) {
        for window in NSApp.windows where window.title == title {
            guard window.identifier != directorWindowID else { continue }
            window.isRestorable = false
            window.close()
        }
    }

    private static func visibleDirectorWindow() -> NSWindow? {
        NSApp.windows.first { window in
            guard window.isVisible else { return false }
            if window.identifier == directorWindowID { return true }
            if auxiliaryTitles.contains(window.title) { return false }
            if window.title.isEmpty { return false }
            if window.identifier?.rawValue == "program-output" { return false }
            return window.canBecomeMain
        }
    }
}

final class MacDirectorWindowDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DirectorMainWindowRecovery.schedule()
    }
}
#endif
