#if os(iOS)
import SwiftUI
import UIKit
import EasyStreamUIComponents

/// Presents the preview multiview on a connected iPad external display via `UIWindow`.
@MainActor
final class PreviewMonitorExternalDisplayController {
    static let shared = PreviewMonitorExternalDisplayController()

    private var externalWindow: UIWindow?
    private var observers: [NSObjectProtocol] = []

    var isPresentingOnExternalDisplay: Bool {
        guard let externalWindow else { return false }
        return !externalWindow.isHidden
    }

    private init() {}

    func installLifecycleObserversIfNeeded() {
        guard observers.isEmpty else { return }
        let center = NotificationCenter.default
        observers.append(
            center.addObserver(
                forName: UIScreen.didDisconnectNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in self?.handleExternalScreenDisconnected() }
            }
        )
    }

    /// Returns `true` when the monitor was shown on an external display.
    @discardableResult
    func present(openOnExternalDisplay: Bool) -> Bool {
        guard openOnExternalDisplay else { return false }
        guard let screen = Self.preferredExternalScreen else { return false }

        dismiss()

        let hosting = UIHostingController(
            rootView: DirectorPreviewMonitorWindowView()
                .broadcastStudioWindowStyle()
                .preferredColorScheme(.dark)
        )
        hosting.view.backgroundColor = .black

        let window: UIWindow
        if let scene = Self.windowScene(for: screen) {
            window = UIWindow(windowScene: scene)
        } else {
            window = UIWindow(frame: screen.bounds)
            window.screen = screen
        }
        window.rootViewController = hosting
        window.frame = screen.bounds
        window.isHidden = false
        window.makeKeyAndVisible()
        externalWindow = window

        DirectorPreviewMonitorStore.shared.restartPaginationIfNeeded()
        return true
    }

    func dismiss() {
        externalWindow?.isHidden = true
        externalWindow?.rootViewController = nil
        externalWindow = nil
        DirectorPreviewMonitorStore.shared.stopPagination()
    }

    private func handleExternalScreenDisconnected() {
        guard isPresentingOnExternalDisplay, Self.preferredExternalScreen == nil else { return }
        dismiss()
    }

    static var hasExternalDisplay: Bool {
        preferredExternalScreen != nil
    }

    static var isExternalDisplayMirroring: Bool {
        guard let external = preferredExternalScreen else { return false }
        return external.mirrored != nil
    }

    static var preferredExternalScreen: UIScreen? {
        allConnectedScreens().first { $0 != UIScreen.main }
    }

    static func allConnectedScreens() -> [UIScreen] {
        var screens: [UIScreen] = [UIScreen.main]

        let sceneScreens = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .map { $0.screen }
        for screen in sceneScreens where !screens.contains(screen) {
            screens.append(screen)
        }

        for screen in UIScreen.screens where !screens.contains(screen) {
            screens.append(screen)
        }

        return screens
    }

    private static func windowScene(for screen: UIScreen) -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.screen == screen }
    }
}
#endif
