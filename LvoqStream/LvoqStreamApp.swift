//
//  LvoqStreamApp.swift
//  LvoqStream
//

import SwiftUI
import LvoqStreamCore
import LvoqStreamFacebook
import LvoqStreamUIComponents
import LvoqStreamVideoPipeline
#if os(iOS)
import LvoqStreamFacebookLogin
#endif

@main
struct LvoqStreamApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#elseif os(macOS)
    @NSApplicationDelegateAdaptor(MacDirectorWindowDelegate.self) private var macDelegate
#endif

    init() {
        ProgramInfrastructureBootstrap.installLiveAdapters()
#if os(iOS)
        LvoqStreamFacebookLoginSetup.install()
#endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .appLocaleEnvironment()
                .broadcastStudioWindowStyle()
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
        Window(BundleLocalization.string("window.preview_monitor"), id: "preview-monitor") {
            DirectorPreviewMonitorWindowView()
                .appLocaleEnvironment()
                .broadcastStudioWindowStyle()
        }
        .defaultSize(width: 1280, height: 720)

        Window(BundleLocalization.string("window.studio_settings"), id: "director-studio-settings") {
            DirectorStudioSettingsWindowView()
                .appLocaleEnvironment()
                .broadcastStudioWindowStyle()
        }
        .defaultSize(width: 760, height: 680)

        WindowGroup(id: "director-widget-studio", for: String.self) { _ in
            DirectorWidgetStudioWindowView()
                .appLocaleEnvironment()
                .broadcastStudioWindowStyle()
        }
        .defaultSize(width: 720, height: 780)

        Window(BundleLocalization.string("window.stream_settings"), id: "director-stream-settings") {
            DirectorStreamSettingsWindowView()
                .appLocaleEnvironment()
                .broadcastStudioWindowStyle()
        }
        .defaultSize(width: 440, height: 320)

        Window("", id: "program-output") {
            DirectorProgramOutputWindowView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1280, height: 720)
#endif
    }
}
