import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

enum AppRoute: Hashable {
    case roleSelection
    case session(AppRole)
}

@MainActor
@Observable
final class AppCoordinator {
    var selectedRole: AppRole? {
        didSet { persistRole() }
    }

    private let roleStorageKey = "com.easystream.selectedRole"

    init() {
        if let raw = UserDefaults.standard.string(forKey: roleStorageKey),
           let role = AppRole(rawValue: raw) {
            selectedRole = role
        }
    }

    func resetRole() {
        selectedRole = nil
        UserDefaults.standard.removeObject(forKey: roleStorageKey)
    }

    private func persistRole() {
        if let selectedRole {
            UserDefaults.standard.set(selectedRole.rawValue, forKey: roleStorageKey)
        }
    }
}

struct RootView: View {
    @State private var coordinator = AppCoordinator()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Folded iPhone Duo and a regular iPhone are compact. The inner Duo display and iPad are regular.
    private var offersDirector: Bool {
        AppRoleAvailability.current(horizontalSizeClass: horizontalSizeClass).offersDirector
    }

    var body: some View {
        NavigationStack {
            if !offersDirector {
                CameraSessionView()
            } else if let role = coordinator.selectedRole {
                sessionView(for: role)
                    .toolbar {
                        if role == .camera {
                            ToolbarItem(placement: .cancellationAction) {
                                Button {
                                    coordinator.resetRole()
                                } label: {
                                    Image(systemName: "chevron.backward")
                                }
                                .accessibilityLabel("Cambiar rol")
                            }
                        }
                    }
            } else {
                RoleSelectionScreen(
                    selectedRole: $coordinator.selectedRole,
                    suggestedRole: .director
                )
            }
        }
        .background(BroadcastTheme.panelBackground)
#if os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .broadcastHiddenWindowToolbar()
        .broadcastTitlebarSafeArea()
#endif
    }

    @ViewBuilder
    private func sessionView(for role: AppRole) -> some View {
        switch role {
        case .director:
            DirectorSessionView(onLeaveRole: { coordinator.resetRole() })
        case .camera:
            CameraSessionView()
        }
    }
}

#Preview {
    RootView()
}
