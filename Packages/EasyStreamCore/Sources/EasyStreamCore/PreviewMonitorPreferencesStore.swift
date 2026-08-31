import Foundation

public enum PreviewMonitorPreferencesStore {
    private static let key = "com.easystream.previewMonitorSettings"

    public static func load() -> PreviewMonitorSettings {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let settings = try? JSONDecoder().decode(PreviewMonitorSettings.self, from: data)
        else {
            return PreviewMonitorSettings()
        }
        return settings
    }

    public static func save(_ settings: PreviewMonitorSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
