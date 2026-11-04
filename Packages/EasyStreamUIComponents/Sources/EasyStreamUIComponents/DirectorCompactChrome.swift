import SwiftUI

public enum DirectorColumnHeaderMetrics {
    /// One height for Cámaras, Vista previa, and Biblioteca on every device.
    public static let height: CGFloat = 48
    public static let horizontalPadding: CGFloat = 12
}

private struct DirectorCompactChromeKey: EnvironmentKey {
    static let defaultValue = false
}

public extension EnvironmentValues {
    /// Tighter director chrome for a regular-but-narrow window, such as iPhone Duo unfolded.
    var directorCompactChrome: Bool {
        get { self[DirectorCompactChromeKey.self] }
        set { self[DirectorCompactChromeKey.self] = newValue }
    }
}
