import SwiftUI
import LvoqStreamCore
import LvoqStreamUIComponents

struct RoleSelectionScreen: View {
    @Binding var selectedRole: AppRole?
    var suggestedRole: AppRole = .director
    var availableRoles: [AppRole] = AppRole.allCases
    @State private var draftRole: AppRole?

    private let identity = DeviceIdentity.current()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                RoleSelectionView(
                    selectedRole: $draftRole,
                    suggestedRole: suggestedRole,
                    availableRoles: availableRoles,
                    deviceName: identity.displayName
                )

                if draftRole != nil {
                    Button(L10n.Common.continue) {
                        selectedRole = draftRole
                    }
                    .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
                    .controlSize(.large)
                    .frame(maxWidth: 640)
                }
            }
            .padding()
        }
        .navigationTitle(BundleLocalization.string("Configuración"))
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .onAppear {
            let fallback = availableRoles.contains(suggestedRole) ? suggestedRole : availableRoles.first
            draftRole = selectedRole ?? fallback
        }
    }
}

#Preview {
    NavigationStack {
        RoleSelectionScreen(selectedRole: .constant(nil))
    }
}
