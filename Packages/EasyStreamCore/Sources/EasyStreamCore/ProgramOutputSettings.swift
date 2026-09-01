import Foundation

public struct ProgramOutputDisplayOption: Identifiable, Sendable, Equatable, Codable {
    public var id: Int
    public var name: String
    public var width: Int
    public var height: Int
    public var isBuiltIn: Bool

    public init(id: Int, name: String, width: Int, height: Int, isBuiltIn: Bool) {
        self.id = id
        self.name = name
        self.width = width
        self.height = height
        self.isBuiltIn = isBuiltIn
    }
}

public struct ProgramOutputSettings: Codable, Sendable, Equatable {
    public var isEnabled: Bool
    public var selectedScreenIndex: Int
    public var fillScreen: Bool

    public init(
        isEnabled: Bool = false,
        selectedScreenIndex: Int = 1,
        fillScreen: Bool = true
    ) {
        self.isEnabled = isEnabled
        self.selectedScreenIndex = selectedScreenIndex
        self.fillScreen = fillScreen
    }
}

public enum ProgramOutputPreferencesStore {
    private static let key = "com.easystream.programOutput"

    public static func load() -> ProgramOutputSettings {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let settings = try? JSONDecoder().decode(ProgramOutputSettings.self, from: data)
        else {
            return ProgramOutputSettings()
        }
        return settings
    }

    public static func save(_ settings: ProgramOutputSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
