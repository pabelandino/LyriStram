//
//  EasyStreamApp.swift
//  EasyStream
//

import SwiftUI
import EasyStreamFacebook
import EasyStreamUIComponents
import EasyStreamVideoPipeline
#if os(iOS)
import EasyStreamFacebookLogin
#endif

@main
struct EasyStreamApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#elseif os(macOS)
    @NSApplicationDelegateAdaptor(MacDirectorWindowDelegate.self) private var macDelegate
#endif

    init() {
        ProgramInfrastructureBootstrap.installLiveAdapters()
#if os(iOS)
        EasyStreamFacebookLoginSetup.install()
#endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
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
        Window("Monitor multiview", id: "preview-monitor") {
            DirectorPreviewMonitorWindowView()
                .broadcastStudioWindowStyle()
        }
        .defaultSize(width: 1280, height: 720)

        Window("Ajustes del estudio", id: "director-studio-settings") {
            DirectorStudioSettingsWindowView()
                .broadcastStudioWindowStyle()
        }
        .defaultSize(width: 760, height: 680)

        WindowGroup(id: "director-widget-studio", for: String.self) { _ in
            DirectorWidgetStudioWindowView()
                .broadcastStudioWindowStyle()
        }
        .defaultSize(width: 720, height: 780)

        Window("Destino RTMPS", id: "director-stream-settings") {
            DirectorStreamSettingsWindowView()
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
