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

        Window("Destino RTMPS", id: "director-stream-settings") {
            DirectorStreamSettingsWindowView()
                .broadcastStudioWindowStyle()
        }
        .defaultSize(width: 440, height: 320)

        Window("", id: "program-output") {
            DirectorProgramOutputWindowView()
                .broadcastStudioWindowStyle()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
#endif
    }
}
