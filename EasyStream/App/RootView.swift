import SwiftUI
import EasyStreamCore

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

    var body: some View {
        NavigationStack {
            if let role = coordinator.selectedRole {
                sessionView(for: role)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cambiar rol") {
                                coordinator.resetRole()
                            }
                        }
                    }
            } else {
                RoleSelectionScreen(selectedRole: $coordinator.selectedRole)
            }
        }
#if os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
    }

    @ViewBuilder
    private func sessionView(for role: AppRole) -> some View {
        switch role {
        case .director:
            DirectorSessionView()
        case .camera:
            CameraSessionView()
        }
    }
}

#Preview {
    RootView()
}
