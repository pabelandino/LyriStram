import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct RoleSelectionScreen: View {
    @Binding var selectedRole: AppRole?
    @State private var draftRole: AppRole?

    private let identity = DeviceIdentity.current()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                RoleSelectionView(
                    selectedRole: $draftRole,
                    suggestedRole: DeviceIdentity.suggestedRole,
                    deviceName: identity.displayName
                )

                if draftRole != nil {
                    Button("Continuar") {
                        selectedRole = draftRole
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: 640)
                }
            }
            .padding()
        }
        .navigationTitle("Configuración")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .onAppear {
            draftRole = selectedRole ?? DeviceIdentity.suggestedRole
        }
    }
}

#Preview {
    NavigationStack {
        RoleSelectionScreen(selectedRole: .constant(nil))
    }
}
