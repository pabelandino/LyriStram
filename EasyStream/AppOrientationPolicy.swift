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

    private static func rotateToLandscapeIfNeeded() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let prefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscape)
        scene.requestGeometryUpdate(prefs) { _ in }
    }
}
#endif
