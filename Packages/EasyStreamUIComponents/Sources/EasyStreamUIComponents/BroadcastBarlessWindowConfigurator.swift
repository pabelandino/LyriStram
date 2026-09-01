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
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(.fullSizeContentView)
        window.isMovableByWindowBackground = false
        window.backgroundColor = NSColor(BroadcastTheme.panelBackground)
        window.titlebarSeparatorStyle = .none
        window.toolbarStyle = .unifiedCompact
        window.toolbar?.displayMode = .iconOnly
    }
}
#endif
