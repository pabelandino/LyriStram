#if os(iOS)
import UIKit

/// Controls supported interface orientations for the active session.
@MainActor
public enum AppOrientationPolicy {
    public static var supportedMask: UIInterfaceOrientationMask = .allButUpsideDown

    public static func lockLandscape() {
        supportedMask = .landscape
        rotateToLandscapeIfNeeded()
    }

    public static func unlock() {
        supportedMask = .allButUpsideDown
    }

    /// Fully open iPhone Duo inner display stays landscape. iPad keeps free rotation.
    public static func apply(phone: Bool, regularWidth: Bool) {
        if phone || !regularWidth {
            lockLandscape()
        } else {
            unlock()
        }
    }

    private static func rotateToLandscapeIfNeeded() {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let active = scenes.filter { $0.activationState == .foregroundActive }
        let prefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscape)
        for scene in (active.isEmpty ? scenes : active) {
            scene.requestGeometryUpdate(prefs) { _ in }
        }
    }
}
#endif
