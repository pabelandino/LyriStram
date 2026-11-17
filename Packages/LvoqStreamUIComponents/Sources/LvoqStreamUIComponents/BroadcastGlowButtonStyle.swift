import SwiftUI

public struct BroadcastGlowButtonStyle: ButtonStyle {
    let tint: Color
    let isProminent: Bool

    public init(tint: Color, isProminent: Bool = true) {
        self.tint = tint
        self.isProminent = isProminent
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .foregroundStyle(isProminent ? Color.white : tint)
            .background {
                if isProminent {
                    RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.95), tint.opacity(0.72)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: tint.opacity(configuration.isPressed ? 0.15 : 0.45), radius: 12, y: 4)
                } else if #available(macOS 26.0, iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                        .fill(.clear)
                        .glassEffect(.regular, in: .rect(cornerRadius: BroadcastGlassStyles.buttonCornerRadius))
                        .overlay {
                            RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                                .strokeBorder(tint.opacity(0.35), lineWidth: 1)
                        }
                } else {
                    RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                                .strokeBorder(tint.opacity(0.35), lineWidth: 1)
                        }
                }
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
