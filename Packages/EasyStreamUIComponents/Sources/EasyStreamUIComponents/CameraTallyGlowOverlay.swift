import SwiftUI
import EasyStreamCore

public enum CameraTallyGlowPlacement {
    /// Full-screen edge glow matching the iPhone display bezel.
    case screenEdge
    /// Glow around embedded preview content (iPad / inset preview).
    case contentFrame(cornerRadius: CGFloat)

    var cornerRadius: CGFloat {
        switch self {
        case .screenEdge: 44
        case .contentFrame(let radius): radius
        }
    }

    var edgeInset: CGFloat {
        switch self {
        case .screenEdge: 5
        case .contentFrame: 0
        }
    }
}

/// Pulsing edge glow shown on the camera device when the Director assigns preview or program.
public struct CameraTallyGlowOverlay: View {
    let assignment: CameraSwitcherAssignment
    var placement: CameraTallyGlowPlacement = .screenEdge

    public init(
        assignment: CameraSwitcherAssignment,
        placement: CameraTallyGlowPlacement = .screenEdge
    ) {
        self.assignment = assignment
        self.placement = placement
    }

    /// Backward-compatible initializer.
    public init(assignment: CameraSwitcherAssignment, lineWidth: CGFloat) {
        self.assignment = assignment
        self.placement = .screenEdge
    }

    public var body: some View {
        if assignment.isActive {
            GeometryReader { proxy in
                let cornerRadius = placement.cornerRadius
                let inset = placement.edgeInset
                let width = max(0, proxy.size.width - inset * 2)
                let height = max(0, proxy.size.height - inset * 2)

                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(glowColor.opacity(0.35), lineWidth: 14)
                        .frame(width: width, height: height)
                        .blur(radius: 10)

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(glowColor.opacity(0.85), lineWidth: 2.5)
                        .frame(width: width, height: height)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    private var glowColor: Color {
        BroadcastTheme.assignmentGlowColor(assignment)
    }
}

public struct CameraAssignmentBadge: View {
    let assignment: CameraSwitcherAssignment

    public init(assignment: CameraSwitcherAssignment) {
        self.assignment = assignment
    }

    public var body: some View {
        if assignment.isActive {
            HStack(spacing: 6) {
                Circle()
                    .fill(BroadcastTheme.assignmentColor(assignment))
                    .frame(width: 8, height: 8)
                    .shadow(color: BroadcastTheme.assignmentGlowColor(assignment).opacity(0.85), radius: 8)
                Text(assignment.displayName.uppercased())
                    .font(.caption.weight(.black))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.black.opacity(0.55), in: Capsule())
            .overlay(Capsule().strokeBorder(BroadcastTheme.assignmentColor(assignment).opacity(0.7), lineWidth: 1))
            .foregroundStyle(BroadcastTheme.assignmentColor(assignment))
        }
    }
}
