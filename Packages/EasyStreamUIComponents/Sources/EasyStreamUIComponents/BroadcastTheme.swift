import SwiftUI
import EasyStreamCore

/// Broadcast streaming color system — PVW green, PRG red, audio gold, studio violet. No system blues.
public enum BroadcastTheme {
    // Tally (on-air semantics)
    public static let previewGreen = Color(red: 0.14, green: 0.82, blue: 0.42)
    public static let programRed = Color(red: 0.95, green: 0.28, blue: 0.33)
    public static let audioGold = Color(red: 0.96, green: 0.74, blue: 0.26)

    /// @deprecated Use `audioGold` — kept so older call sites compile during migration.
    public static let audioBlue = audioGold

    // Studio UI chrome
    public static let studioAccent = Color(red: 0.62, green: 0.52, blue: 0.96)
    public static let controlAccent = Color(red: 0.72, green: 0.58, blue: 0.98)
    public static let liveAmber = Color(red: 1.0, green: 0.58, blue: 0.16)
    public static let copper = Color(red: 0.88, green: 0.52, blue: 0.28)

    // Surfaces
    public static let glassHighlight = Color.white.opacity(0.14)
    public static let panelBackground = Color(red: 0.06, green: 0.07, blue: 0.09)
    public static let panelElevated = Color(red: 0.09, green: 0.10, blue: 0.13)
    public static let panelBorder = Color.white.opacity(0.09)
    public static let primaryText = Color.white.opacity(0.92)
    public static let subtleText = Color.white.opacity(0.56)
    public static let workspaceDivider = Color.white.opacity(0.05)

    public static func assignmentColor(_ assignment: CameraSwitcherAssignment) -> Color {
        switch assignment {
        case .idle: .clear
        case .preview: previewGreen
        case .program, .previewAndProgram: programRed
        }
    }

    public static func assignmentGlowColor(_ assignment: CameraSwitcherAssignment) -> Color {
        assignmentColor(assignment)
    }
}
