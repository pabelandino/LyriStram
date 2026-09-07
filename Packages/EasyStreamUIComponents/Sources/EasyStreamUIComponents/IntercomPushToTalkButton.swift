import SwiftUI
import EasyStreamCore

public struct IntercomPushToTalkButton: View {
    let isEnabled: Bool
    let isTalking: Bool
    let isActivating: Bool
    let targetDisplayName: String?
    let onToggle: () -> Void

    private var isLive: Bool { isTalking && !isActivating }

    public init(
        isEnabled: Bool,
        isTalking: Bool,
        isActivating: Bool = false,
        targetDisplayName: String? = nil,
        onToggle: @escaping () -> Void
    ) {
        self.isEnabled = isEnabled
        self.isTalking = isTalking
        self.isActivating = isActivating
        self.targetDisplayName = targetDisplayName
        self.onToggle = onToggle
    }

    public var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                micIcon

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                    Text(subtitle)
                        .font(.caption2.weight(.medium))
                        .opacity(0.88)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, isLive ? 16 : 14)
            .frame(maxWidth: .infinity)
            .background { buttonBackground }
            .foregroundStyle(.white)
            .clipShape(buttonShape)
            .overlay {
                if isActivating {
                    IntercomActivationRing(cornerRadius: idleCornerRadius)
                } else if isLive {
                    IntercomPushToTalkPulseRings(cornerRadius: activeCornerRadius)
                }
            }
            .overlay {
                buttonShape
                    .strokeBorder(
                        ringColor.opacity(isActivating || isLive ? 0.55 : 0.12),
                        lineWidth: isActivating ? 2.5 : 1
                    )
            }
            .shadow(
                color: ringColor.opacity(isLive ? 0.55 : isActivating ? 0.45 : 0.35),
                radius: isLive ? 16 : isActivating ? 12 : 8,
                y: isLive ? 6 : 3
            )
            .scaleEffect(isLive ? 1.03 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isLive)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isActivating)
        .opacity(isEnabled ? 1 : 0.45)
    }

    private var title: String {
        if isActivating {
            return "Activando intercom…"
        }
        if isLive {
            if let targetDisplayName {
                return "Hablando con \(targetDisplayName)"
            }
            return "Intercom activo"
        }
        return "Toca para hablar"
    }

    private var subtitle: String {
        if isActivating {
            return "Preparando micrófono del intercom"
        }
        if isLive {
            return "Toca de nuevo para silenciar"
        }
        if let targetDisplayName {
            return "Intercom · \(targetDisplayName)"
        }
        return "Elige un destinatario arriba"
    }

    private var ringColor: Color {
        if isActivating {
            return BroadcastTheme.studioAccent
        }
        return isLive ? BroadcastTheme.programRed : BroadcastTheme.studioAccent
    }

    @ViewBuilder
    private var micIcon: some View {
        let icon = Image(systemName: iconName)
            .font(.title3.weight(.semibold))
        if #available(iOS 17.0, macOS 14.0, *) {
            icon.symbolEffect(.variableColor.iterative.reversing, isActive: isLive)
        } else {
            icon
        }
    }

    private var iconName: String {
        if isActivating {
            return "mic.badge.plus"
        }
        return isLive ? "waveform.circle.fill" : "mic.fill"
    }

    private var idleCornerRadius: CGFloat { 12 }
    private var activeCornerRadius: CGFloat { 22 }

    private var buttonShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: isLive ? activeCornerRadius : idleCornerRadius,
            style: .continuous
        )
    }

    @ViewBuilder
    private var buttonBackground: some View {
        if isLive {
            LinearGradient(
                colors: [
                    BroadcastTheme.programRed,
                    BroadcastTheme.liveAmber.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                colors: [
                    BroadcastTheme.studioAccent.opacity(0.95),
                    BroadcastTheme.controlAccent.opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
