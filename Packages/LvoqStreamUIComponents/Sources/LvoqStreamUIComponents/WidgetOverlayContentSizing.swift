import SwiftUI
import LvoqStreamCore

public enum WidgetOverlayContentSizing: Sendable {
    case fillFrame
    /// Logos use a square frame so handles hug the visible logo bounds.
    case uniformSquare
}
