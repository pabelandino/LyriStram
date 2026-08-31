import Foundation

public enum TransitionPreferencesStore {
    private static let key = "com.easystream.preferredTransition"

    public static func load() -> SwitchTransition {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let transition = try? JSONDecoder().decode(SwitchTransition.self, from: data)
        else {
            return .dissolve
        }
        return transition
    }

    public static func save(_ transition: SwitchTransition) {
        guard let data = try? JSONEncoder().encode(transition) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
