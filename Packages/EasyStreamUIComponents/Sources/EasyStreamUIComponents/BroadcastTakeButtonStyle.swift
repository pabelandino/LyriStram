import SwiftUI

/// Prominent take-to-program control with hover + pressed feedback (macOS and iOS).
public struct BroadcastTakeButtonStyle: ButtonStyle {
    let isHovered: Bool
    let isPressing: Bool
    private let tint = BroadcastTheme.programRed

    public init(isHovered: Bool = false, isPressing: Bool = false) {
        self.isHovered = isHovered
        self.isPressing = isPressing
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || isPressing
        let isHighlighted = isHovered && !isPressed

        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.white.opacity(isPressed ? 0.88 : 1))
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                        .fill(buttonGradient(isPressed: isPressed, isHighlighted: isHighlighted))

                    RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                        .strokeBorder(
                            Color.white.opacity(isPressed ? 0.1 : (isHighlighted ? 0.34 : 0.22)),
                            lineWidth: isHighlighted ? 1.5 : 1
                        )

                    if !isPressed {
                        RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(isHighlighted ? 0.2 : 0.12), lineWidth: 1)
                            .blur(radius: 0.5)
                            .offset(y: -0.5)
                            .mask {
                                RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [.white, .clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )
                            }
                    }
                }
                .shadow(
                    color: tint.opacity(isPressed ? 0.1 : (isHighlighted ? 0.55 : 0.42)),
                    radius: isPressed ? 2 : (isHighlighted ? 14 : 10),
                    y: isPressed ? 1 : (isHighlighted ? 6 : 5)
                )
            }
            .overlay {
                RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                    .fill(Color.black.opacity(isPressed ? 0.32 : (isHighlighted ? 0.06 : 0)))
            }
            .scaleEffect(isPressed ? 0.95 : (isHighlighted ? 1.02 : 1), anchor: .center)
            .offset(y: isPressed ? 3 : 0)
            .brightness(isHighlighted ? 0.06 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.68), value: isPressed)
            .animation(.easeOut(duration: 0.14), value: isHighlighted)
    }

    private func buttonGradient(isPressed: Bool, isHighlighted: Bool) -> LinearGradient {
        LinearGradient(
            colors: [
                tint.opacity(isPressed ? 0.62 : (isHighlighted ? 1 : 0.95)),
                tint.opacity(isPressed ? 0.48 : (isHighlighted ? 0.82 : 0.72))
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
