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

            Menu {
                ForEach(SwitchTransitionKind.allCases) { kind in
                    Button {
                        transition.kind = kind
                        if kind == .cut {
                            transition.duration = 0
                        } else if transition.duration <= 0 {
                            transition.duration = SwitchTransition.defaultDuration(for: kind)
                        }
                    } label: {
                        if kind == transition.kind {
                            Label(kind.displayName, systemImage: "checkmark")
                        } else {
                            Text(kind.displayName)
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(transition.kind.displayName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(BroadcastTheme.primaryText)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BroadcastTheme.subtleText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BroadcastTheme.panelBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1)
                }
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .buttonStyle(.plain)

            if transition.kind != .cut {
                HStack {
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
}
