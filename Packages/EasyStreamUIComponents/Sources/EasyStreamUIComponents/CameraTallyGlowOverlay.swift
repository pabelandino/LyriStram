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

    @State private var pulse = false

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
                    glowLayer(
                        cornerRadius: cornerRadius,
                        width: width,
                        height: height,
                        lineWidth: 18,
                        blur: pulse ? 26 : 12,
                        opacity: pulse ? 0.5 : 0.18
                    )

                    glowLayer(
                        cornerRadius: cornerRadius,
                        width: width,
                        height: height,
                        lineWidth: 10,
                        blur: pulse ? 14 : 6,
                        opacity: pulse ? 0.72 : 0.32
                    )

                    glowLayer(
                        cornerRadius: cornerRadius,
                        width: width,
                        height: height,
                        lineWidth: 4,
                        blur: pulse ? 4 : 1,
                        opacity: pulse ? 0.95 : 0.55
                    )

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(glowColor.opacity(pulse ? 1 : 0.75), lineWidth: 2)
                        .frame(width: width, height: height)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .scaleEffect(pulse ? 1.003 : 0.997)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .onAppear { startPulse() }
            .onChange(of: assignment) { _, _ in startPulse() }
        }
    }

    private func glowLayer(
        cornerRadius: CGFloat,
        width: CGFloat,
        height: CGFloat,
        lineWidth: CGFloat,
        blur: CGFloat,
        opacity: Double
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(glowColor.opacity(opacity), lineWidth: lineWidth)
            .frame(width: width, height: height)
            .blur(radius: blur)
    }

    private var glowColor: Color {
        BroadcastTheme.assignmentGlowColor(assignment)
    }

    private func startPulse() {
        pulse = false
        withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
            pulse = true
        }
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
                    .shadow(color: BroadcastTheme.assignmentGlowColor(assignment).opacity(pulseOpacity), radius: 8)
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

    private var pulseOpacity: Double { 0.85 }
}
