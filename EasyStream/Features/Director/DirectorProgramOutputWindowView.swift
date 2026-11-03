import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorProgramOutputWindowView: View {
    @Bindable private var store = DirectorProgramOutputStore.shared

    var body: some View {
        BroadcastCleanProgramFeedView(
            programDisplayTrack: store.programDisplayTrack,
            outgoingProgramTrack: store.outgoingProgramTrack,
            incomingProgramTrack: store.incomingProgramTrack,
            isTransitioning: store.isTransitioning,
            transitionProgress: store.transitionProgress,
            transitionKind: store.transitionKind,
            widgetLayers: store.widgetLayers,
            fullScreenResource: store.fullScreenResource,
            fullScreenFileURL: store.fullScreenFileURL,
            fullScreenIsLive: store.fullScreenIsLive,
            onWidgetLiveAutoDismiss: { LiveProgramAirStore.shared.requestWidgetAutoDismiss($0) }
        )
        .onAppear {
            store.markWindowOpen()
        }
        .onDisappear {
            store.markWindowClosed()
#if os(macOS)
            ProgramOutputWindowPlacement.restorePresentationOptionsIfNeeded()
#endif
        }
#if os(macOS)
        .background {
            ProgramOutputScreenAnchor(screenIndex: store.settings.selectedScreenIndex)
        }
#endif
    }
}

#if os(macOS)
import AppKit

enum ProgramOutputWindowPlacement {
    private static let windowIdentifier = "program-output"
    private static var placedScreenIndex: Int?

    static func dismissStaleOutputOnLaunch() {
        NSApp.presentationOptions = []
        for window in NSApp.windows where isProgramOutputWindow(window) {
            window.orderOut(nil)
        }
    }

    /// Moves the output window onto another display. Never covers the director or hides its menu bar.
    static func place(_ window: NSWindow, on screenIndex: Int) {
        NSApp.presentationOptions = []
        guard window != NSApp.mainWindow else { return }
        guard DirectorProgramOutputStore.shared.settings.isEnabled else { return }
        guard let validatedIndex = ProgramOutputDisplayDiscovery.validatedExternalScreenIndex(screenIndex),
              let screen = ProgramOutputDisplayDiscovery.screen(for: validatedIndex),
              screen != NSScreen.main
        else { return }

        applyCleanChrome(window)
        let alreadyFillingScreen = placedScreenIndex == validatedIndex
            && window.screen == screen
            && window.frame.equalTo(screen.frame)
        if alreadyFillingScreen {
            return
        }

        window.identifier = NSUserInterfaceItemIdentifier(windowIdentifier)
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isExcludedFromWindowsMenu = true
        window.isMovable = false
        window.setFrame(screen.frame, display: true, animate: false)
        window.orderFront(nil)
        placedScreenIndex = validatedIndex
        directorWindow()?.makeKey()
    }

    /// Full-bleed program. No title, toolbar, or shadow. Does not change the director's menu bar.
    private static func applyCleanChrome(_ window: NSWindow) {
        window.title = ""
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .none
        window.styleMask.insert(.fullSizeContentView)
        window.toolbar = nil
        window.isReleasedWhenClosed = false
        window.backgroundColor = .black
        window.isOpaque = true
        window.hasShadow = false
    }

    static func restorePresentationOptionsIfNeeded() {
        NSApp.presentationOptions = []
    }

    static func closeOutputWindow() {
        placedScreenIndex = nil
        for window in NSApp.windows where isProgramOutputWindow(window) {
            window.orderOut(nil)
        }
        restorePresentationOptionsIfNeeded()
    }

    private static func isProgramOutputWindow(_ window: NSWindow) -> Bool {
        window.identifier?.rawValue == windowIdentifier && window != NSApp.mainWindow
    }

    private static func directorWindow() -> NSWindow? {
        NSApp.mainWindow ?? NSApp.windows.first { $0.identifier?.rawValue != windowIdentifier && $0.canBecomeKey }
    }
}

/// Reads the SwiftUI output window and parks it on the selected external display.
private struct ProgramOutputScreenAnchor: NSViewRepresentable {
    var screenIndex: Int

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        context.coordinator.screenIndex = screenIndex
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.screenIndex = screenIndex
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            ProgramOutputWindowPlacement.place(window, on: context.coordinator.screenIndex)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var screenIndex = 0
    }
}
#endif
