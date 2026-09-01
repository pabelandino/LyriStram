import SwiftUI
import EasyStreamCore

public struct RoleSelectionView: View {
    @Binding var selectedRole: AppRole?
    let suggestedRole: AppRole
    let deviceName: String

    public init(selectedRole: Binding<AppRole?>, suggestedRole: AppRole, deviceName: String) {
        _selectedRole = selectedRole
        self.suggestedRole = suggestedRole
        self.deviceName = deviceName
    }

    public var body: some View {
        VStack(spacing: 32) {
            header
            roleCards
            footer
        }
        .padding(24)
        .frame(maxWidth: 640)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
                .symbolRenderingMode(.hierarchical)

            Text("EasyStream")
                .font(.largeTitle.bold())

            Text("¿Cómo quieres usar **\(deviceName)**?")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private var roleCards: some View {
        VStack(spacing: 16) {
            ForEach(AppRole.allCases) { role in
                RoleCard(
                    role: role,
                    isSuggested: role == suggestedRole,
                    isSelected: selectedRole == role
                ) {
                    selectedRole = role
                }
            }
        }
    }

    private var footer: some View {
        Text("El tráfico de cámaras permanece en tu red Wi‑Fi local.")
            .font(.footnote)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
    }
}

private struct RoleCard: View {
    let role: AppRole
    let isSuggested: Bool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: role.systemImageName)
                    .font(.title)
                    .frame(width: 44)
                    .foregroundStyle(isSelected ? .white : .accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(role.displayName)
                            .font(.headline)
                        if isSuggested {
                            Text("Recomendado")
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.quaternary, in: Capsule())
                        }
                    }
                    Text(role.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(isSelected ? .white.opacity(0.85) : .secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.tertiary))
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        isSelected
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        BroadcastTheme.studioAccent.opacity(0.95),
                                        BroadcastTheme.controlAccent.opacity(0.78)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(.background.secondary)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? Color.clear : Color.primary.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    RoleSelectionView(
        selectedRole: .constant(.director),
        suggestedRole: .director,
        deviceName: "iPad Pro"
    )
}
