import Foundation

public enum LyrioraPresentationMode: String, Codable, CaseIterable, Sendable {
    case lower
    case fullScreen

    public var title: String {
        switch self {
        case .lower: "Lower"
        case .fullScreen: "Pantalla completa"
        }
    }
}
