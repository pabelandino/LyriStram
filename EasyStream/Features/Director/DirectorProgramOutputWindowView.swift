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
#if os(macOS)
            guard store.settings.isEnabled,
                  let screenIndex = ProgramOutputDisplayDiscovery.validatedExternalScreenIndex(
                    store.settings.selectedScreenIndex
                  )
            else {
                store.markWindowClosed()
                ProgramOutputWindowPlacement.dismissStaleOutputOnLaunch()
                return
            }
            ProgramOutputWindowPlacement.presentFullscreen(on: screenIndex)
#endif
        }
        .onDisappear {
            store.markWindowClosed()
        }
        .onChange(of: store.settings.selectedScreenIndex) { _, newIndex in
#if os(macOS)
            guard store.isWindowOpen, store.settings.isEnabled,
                  let screenIndex = ProgramOutputDisplayDiscovery.validatedExternalScreenIndex(newIndex)
            else { return }
            ProgramOutputWindowPlacement.presentFullscreen(on: screenIndex)
#endif
        }
    }
}

#if os(macOS)
import AppKit

enum ProgramOutputWindowPlacement {
    private static let windowIdentifier = "program-output"

    static func dismissStaleOutputOnLaunch() {
        locateProgramWindow()?.orderOut(nil)
        NSApp.presentationOptions = []
    }

    static func presentFullscreen(on screenIndex: Int) {
        guard DirectorProgramOutputStore.shared.settings.isEnabled else { return }
        guard let validatedIndex = ProgramOutputDisplayDiscovery.validatedExternalScreenIndex(screenIndex),
              let screen = ProgramOutputDisplayDiscovery.screen(for: validatedIndex),
              screen != NSScreen.main
        else {
            closeOutputWindow()
            DirectorProgramOutputStore.shared.settings.isEnabled = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            guard DirectorProgramOutputStore.shared.settings.isEnabled else { return }
            guard let window = locateProgramWindow() else { return }
            guard let screen = ProgramOutputDisplayDiscovery.screen(for: validatedIndex) else { return }

            window.identifier = NSUserInterfaceItemIdentifier(windowIdentifier)
            window.title = ""
            window.isReleasedWhenClosed = false
            window.backgroundColor = .black
            window.isOpaque = true
            window.hasShadow = false
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask = [.borderless]
            window.level = .screenSaver
            window.collectionBehavior = [
                .canJoinAllSpaces,
                .fullScreenAuxiliary,
                .stationary,
                .ignoresCycle
            ]
            window.isExcludedFromWindowsMenu = true
            window.isMovable = false
            window.isMovableByWindowBackground = false

            window.setFrame(screen.frame, display: true, animate: false)
            window.orderFrontRegardless()

            NSApp.presentationOptions = [.autoHideMenuBar, .autoHideDock]
        }
    }

    static func restorePresentationOptionsIfNeeded() {
        let hasLiveOutput = DirectorProgramOutputStore.shared.isWindowOpen
        if !hasLiveOutput {
            NSApp.presentationOptions = []
        }
    }

    static func closeOutputWindow() {
        locateProgramWindow()?.orderOut(nil)
        restorePresentationOptionsIfNeeded()
    }

    private static func locateProgramWindow() -> NSWindow? {
        NSApp.windows.first { window in
            window.identifier?.rawValue == windowIdentifier
        }
    }
}
#endif
