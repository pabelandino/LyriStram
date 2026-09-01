//
//  EasyStreamApp.swift
//  EasyStream
//

import SwiftUI
import EasyStreamFacebook
import EasyStreamUIComponents
#if os(iOS)
import EasyStreamFacebookLogin
#endif

@main
struct EasyStreamApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#endif

    init() {
#if os(iOS)
        EasyStreamFacebookLoginSetup.install()
#endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .broadcastStudioChrome()
                .broadcastBarlessWindow()
#if os(iOS)
                .onOpenURL { url in
                    _ = FacebookSDKBootstrap.handleOpenURL(url)
                }
#endif
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1440, height: 900)
#endif

#if os(macOS)
        Window("Monitor multiview", id: "preview-monitor") {
            DirectorPreviewMonitorWindowView()
        }
        .defaultSize(width: 1280, height: 720)

        Window("", id: "program-output") {
            DirectorProgramOutputWindowView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
#endif
    }
}
