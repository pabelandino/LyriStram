import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorPreviewMonitorWindowView: View {
    @Bindable private var store = DirectorPreviewMonitorStore.shared

    var body: some View {
        VStack(spacing: 0) {
            PreviewMonitorHeaderBar(
                cameraCount: store.cameras.count,
                previewName: store.previewDisplayName,
                programName: store.programDisplayName,
                layoutName: store.settings.layoutMode.displayName,
                page: store.currentPage,
                pageCount: store.totalPages
            )

            if store.cameras.isEmpty {
                ContentUnavailableView(
                    "Sin cámaras",
                    systemImage: "video.slash",
                    description: Text("Conecta cámaras al Director para verlas aquí.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            } else {
                PreviewMonitorMultiviewGrid(
                    cameras: store.cameras,
                    previewSourceID: store.previewSourceID,
                    programSourceID: store.programSourceID,
                    programAudioSourceID: store.programAudioSourceID,
                    settings: store.settings,
                    currentPage: store.currentPage,
                    onSelect: { store.selectPreview($0) }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onAppear {
            store.restartPaginationIfNeeded()
#if os(macOS)
            PreviewMonitorWindowPlacement.applyExternalDisplayPreference(store.settings.openOnExternalDisplay)
#endif
        }
        .onDisappear {
            store.stopPagination()
        }
        .onChange(of: store.settings.autoPaginate) { _, _ in
            store.restartPaginationIfNeeded()
        }
        .onChange(of: store.settings.pageIntervalSeconds) { _, _ in
            store.restartPaginationIfNeeded()
        }
        .onChange(of: store.settings.layoutMode) { _, _ in
            store.restartPaginationIfNeeded()
        }
#if os(macOS)
        .background(monitorKeyboardShortcuts)
#endif
    }

#if os(macOS)
    private var monitorKeyboardShortcuts: some View {
        Group {
            ForEach(0..<min(store.cameras.count, 9), id: \.self) { index in
                Button("") {
                    store.selectPreview(store.cameras[index].id)
                }
                .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: [])
                .hidden()
            }
        }
    }
#endif
}

#if os(macOS)
import AppKit

enum PreviewMonitorWindowPlacement {
    private static let monitorTitle = "Monitor multiview"

    static func applyExternalDisplayPreference(_ openOnExternalDisplay: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            guard let window = locateMonitorWindow() else { return }
            window.title = monitorTitle
            window.isReleasedWhenClosed = false
            guard openOnExternalDisplay else { return }
            moveToPreferredExternalScreen(window)
        }
    }

    static func moveToPreferredExternalScreen(_ window: NSWindow) {
        let screens = NSScreen.screens
        guard let target = screens.count > 1 ? screens[1] : screens.first else { return }
        window.setFrame(target.visibleFrame, display: true, animate: true)
    }

    private static func locateMonitorWindow() -> NSWindow? {
        NSApp.windows.last { window in
            window.title == monitorTitle || window.identifier?.rawValue == "preview-monitor"
        } ?? NSApp.windows.last
    }
}
#endif
