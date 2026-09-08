import SwiftUI
import EasyStreamCore

public struct SwitchTransitionControls: View {
    @Binding var transition: SwitchTransition

    public init(transition: Binding<SwitchTransition>) {
        _transition = transition
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Transición")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BroadcastTheme.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SwitchTransitionKind.allCases) { kind in
                        transitionChip(for: kind)
                    }
                }
                .padding(.vertical, 2)
            }

            if transition.kind != .cut {
                HStack(spacing: 10) {
                    Text("Duración")
                        .font(.caption)
                        .foregroundStyle(BroadcastTheme.subtleText)
                    Slider(value: $transition.duration, in: 0.2...2.0, step: 0.1)
                        .tint(BroadcastTheme.studioAccent)
                    Text(String(format: "%.1fs", transition.duration))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(BroadcastTheme.subtleText)
                        .frame(width: 36, alignment: .trailing)
                }
            }
        }
    }

    private func transitionChip(for kind: SwitchTransitionKind) -> some View {
        let isSelected = transition.kind == kind

        return Button {
            transition.kind = kind
            if kind == .cut {
                transition.duration = 0
            } else if transition.duration <= 0 {
                transition.duration = SwitchTransition.defaultDuration(for: kind)
            }
        } label: {
            Text(kind.displayName)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? Color.white : BroadcastTheme.primaryText.opacity(0.82))
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            isSelected
                                ? LinearGradient(
                                    colors: [
                                        BroadcastTheme.studioAccent.opacity(0.95),
                                        BroadcastTheme.controlAccent.opacity(0.78)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [
                                        BroadcastTheme.panelBackground,
                                        BroadcastTheme.panelBackground
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(
                            isSelected ? BroadcastTheme.controlAccent.opacity(0.55) : BroadcastTheme.panelBorder,
                            lineWidth: 1
                        )
                }
                .shadow(color: isSelected ? BroadcastTheme.studioAccent.opacity(0.35) : .clear, radius: 8, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
