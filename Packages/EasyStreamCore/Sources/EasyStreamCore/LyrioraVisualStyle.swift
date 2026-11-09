import Foundation

public enum LyrioraVisualStyle: String, Codable, CaseIterable, Sendable {
    case classic
    case studio
    case liturgical

    public var title: String {
        switch self {
        case .classic: "Clásico"
        case .studio: "Estudio"
        case .liturgical: "Litúrgico"
        }
    }
}
