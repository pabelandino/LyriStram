#if os(macOS)
import AppKit
import SwiftUI

/// Configures the main window for a barless, full-size content chrome (traffic lights float over content).
struct BroadcastBarlessWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            applyBarlessChrome(to: window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            applyBarlessChrome(to: window)
        }
    }

    private func applyBarlessChrome(to window: NSWindow) {
        window.appearance = NSAppearance(named: .darkAqua)
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(.fullSizeContentView)
        window.isMovableByWindowBackground = false
        window.backgroundColor = NSColor(BroadcastTheme.panelBackground)
        window.titlebarSeparatorStyle = .none
        window.toolbarStyle = .unifiedCompact
        window.toolbar?.displayMode = .iconOnly
        window.minSize = NSSize(width: 1180, height: 720)
        window.contentMinSize = NSSize(width: 1180, height: 720)
    }
}

/// Locks auxiliary SwiftUI windows to the broadcast dark studio chrome (ignores system light mode).
struct BroadcastWindowAppearanceConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            applyStudioAppearance(to: view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            applyStudioAppearance(to: nsView.window)
        }
    }

    private func applyStudioAppearance(to window: NSWindow?) {
        guard let window else { return }
        window.appearance = NSAppearance(named: .darkAqua)
        window.backgroundColor = NSColor(BroadcastTheme.panelBackground)
    }
}
#endif
