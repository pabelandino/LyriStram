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

public struct BroadcastPanelModifier: ViewModifier {
    let elevated: Bool

    public init(elevated: Bool = false) {
        self.elevated = elevated
    }

    public func body(content: Content) -> some View {
        if #available(macOS 26.0, iOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1)
                }
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(elevated ? BroadcastTheme.panelElevated : BroadcastTheme.panelBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1)
                )
        }
    }
}

public extension View {
    func broadcastPanel(elevated: Bool = false) -> some View {
        modifier(BroadcastPanelModifier(elevated: elevated))
    }
}

public struct BroadcastSectionHeader: View {
    let title: String
    let systemImage: String?

    public init(_ title: String, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }

    public var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(BroadcastTheme.subtleText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }
}

public struct BroadcastFormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    public init(_ title: String, text: Binding<String>, placeholder: String) {
        self.title = title
        _text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
#if os(iOS)
                .textInputAutocapitalization(.never)
#endif
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(BroadcastTheme.panelBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public struct BroadcastInspectorEmptyState: View {
    let title: String
    let systemImage: String

    public init(_ title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
    }

    public var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(BroadcastTheme.subtleText)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(BroadcastTheme.subtleText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

public struct BroadcastTallyPill: View {
    let label: String
    let color: Color

    public init(_ label: String, color: Color) {
        self.label = label
        self.color = color
    }

    public var body: some View {
        Text(label)
            .font(.caption2.weight(.black))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.18), in: Capsule())
            .overlay(Capsule().strokeBorder(color.opacity(0.65), lineWidth: 1))
            .foregroundStyle(color)
    }
}

/// Compact on-air indicator for narrow list rows.
public struct BroadcastCompactLiveBadge: View {
    public init() {}

    public var body: some View {
        Text("AIR")
            .font(.system(size: 9, weight: .black))
            .foregroundStyle(BroadcastTheme.programRed)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(BroadcastTheme.programRed.opacity(0.16), in: Capsule())
            .overlay(Capsule().strokeBorder(BroadcastTheme.programRed.opacity(0.55), lineWidth: 0.75))
            .fixedSize()
            .accessibilityLabel("Al aire")
    }
}
