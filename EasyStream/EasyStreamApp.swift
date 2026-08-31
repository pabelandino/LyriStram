//
//  EasyStreamApp.swift
//  EasyStream
//

import SwiftUI
import EasyStreamFacebook
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
#if os(iOS)
                .onOpenURL { url in
                    _ = FacebookSDKBootstrap.handleOpenURL(url)
                }
#endif
        }

#if os(macOS)
        Window("Monitor multiview", id: "preview-monitor") {
            DirectorPreviewMonitorWindowView()
        }
        .defaultSize(width: 1280, height: 720)
#endif
    }
}
