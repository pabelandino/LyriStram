import Foundation

/// One SwiftUI window value per editing session.
///
/// Closing the window with `NSWindow.close()` left the scene registered, so the
/// next `openWindow(id:)` did nothing. A new value opens a fresh window.
@MainActor
enum WidgetStudioWindowToken {
    private(set) static var value: String?

    @discardableResult
    static func prepare() -> String {
        if let value { return value }
        let created = UUID().uuidString
        value = created
        return created
    }

    static func invalidate() {
        value = nil
    }
}
