#if os(macOS)
import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

extension DirectorSessionView {
    @ViewBuilder
    var platformDirectorBody: some View {
        sessionContent
            .broadcastHiddenWindowToolbar()
            .background(keyboardShortcuts)
    }

    @ViewBuilder
    var platformSwitcherLayout: some View {
        directorWorkspaceLayout
            .background(BroadcastTheme.panelBackground)
    }

    @ToolbarContentBuilder
    var platformDirectorToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            BroadcastTransmissionMenu(
                programOutputSettings: $programOutputStore.settings,
                availableScreens: ProgramOutputDisplayDiscovery.availableScreens(),
                isExternalOutputLive: programOutputStore.isWindowOpen,
                isNetworkPublishing: viewModel.isPublishing,
                isFacebookConfigured: viewModel.isFacebookConfigured,
                isFacebookLoading: viewModel.isFacebookLoading,
                facebookStatusMessage: viewModel.facebookStatusMessage,
                streamDestination: viewModel.streamDestination,
                onStartExternalOutput: startExternalBroadcast,
                onStopExternalOutput: stopExternalBroadcast,
                onPrepareFacebookLive: { viewModel.prepareFacebookLive() },
                onStartNetworkPublish: { viewModel.startPublishing() },
                onStopNetworkPublish: { viewModel.stopPublishing() },
                onOpenStreamSettings: { openStreamSettings() }
            )

            Button {
                openStudioSettings()
            } label: {
                Label("Ajustes", systemImage: "gearshape")
            }
            .help("Calidad, monitor multiview y estudio")

            Button {
                openPreviewMonitor()
            } label: {
                Label("Monitor", systemImage: "display.2")
            }
            .help("Abrir monitor multiview en segunda pantalla")
        }
    }

    func platformDirectorSessionDidAppear() {
        programOutputStore.resetExternalOutputForLaunch()
    }

    func platformPrewarmStudioSettingsWindowIfNeeded() {
        guard !programOutputStore.isWindowOpen, !viewModel.isPublishing else { return }

        openWindow(id: "director-studio-settings")
        Task { @MainActor in
            await DirectorModalPresentation.deferHeavyUI()
            await DirectorModalPresentation.deferHeavyUI()
            dismissWindow(id: "director-studio-settings")
        }
    }

    func openStudioSettings(tab: DirectorStudioSettingsTab = .studio) {
        DirectorWorkspaceSession.shared.requestStudioSettings(tab: tab)
        DirectorModalPresentation.afterYield {
            openWindow(id: "director-studio-settings")
        }
    }

    func openStreamSettings() {
        DirectorModalPresentation.afterYield {
            openWindow(id: "director-stream-settings")
        }
    }

    func openPreviewMonitor() {
        openWindow(id: "preview-monitor")
        PreviewMonitorWindowPlacement.applyExternalDisplayPreference(previewMonitor.settings.openOnExternalDisplay)
        previewMonitor.restartPaginationIfNeeded()
    }

    func openProgramOutput() {
        startExternalBroadcast()
    }

    func startExternalBroadcast() {
        guard ProgramOutputDisplayDiscovery.hasExternalDisplay else { return }
        programOutputStore.sanitizeScreenSelection()
        guard let screenIndex = ProgramOutputDisplayDiscovery.validatedExternalScreenIndex(
            programOutputStore.settings.selectedScreenIndex
        ) else { return }
        programOutputStore.settings.isEnabled = true
        programOutputStore.settings.fillScreen = true
        openWindow(id: "program-output")
        programOutputStore.markWindowOpen()
        ProgramOutputWindowPlacement.presentFullscreen(on: screenIndex)
    }

    func stopExternalBroadcast() {
        dismissWindow(id: "program-output")
        programOutputStore.markWindowClosed()
        programOutputStore.settings.isEnabled = false
        ProgramOutputWindowPlacement.restorePresentationOptionsIfNeeded()
    }

    private var keyboardShortcuts: some View {
        Group {
            ForEach(0..<min(viewModel.sources.count, 9), id: \.self) { index in
                Button("") {
                    if let id = viewModel.source(at: index) {
                        viewModel.selectPreview(id)
                    }
                }
                .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: [])
                .hidden()
            }
        }
    }
}
#endif
