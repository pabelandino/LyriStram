import Foundation

public enum FacebookSessionStore {
    private static let key = "com.easystream.facebookSession"

    public static func load() -> FacebookSession {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let session = try? JSONDecoder().decode(FacebookSession.self, from: data)
        else {
            return FacebookSession()
        }
        return session
    }

    public static func save(_ session: FacebookSession) {
        guard let data = try? JSONEncoder().encode(session) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    public static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
