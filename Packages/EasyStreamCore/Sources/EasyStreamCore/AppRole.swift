import Foundation

/// Application role selected at launch.
public enum AppRole: String, Codable, Sendable, CaseIterable, Identifiable {
    case director
    case camera

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .director: "Director"
        case .camera: "Cámara"
        }
    }

    public var subtitle: String {
        switch self {
        case .director:
            "Recibe cámaras, mezcla y transmite en vivo"
        case .camera:
            "Envía video y audio a un Director en la red local"
        }
    }

    public var systemImageName: String {
        switch self {
        case .director: "rectangle.inset.filled.and.person.filled"
        case .camera: "video.fill"
        }
    }

    /// Bonjour service type this role advertises on the local network.
    public var advertisedServiceType: BonjourServiceType {
        switch self {
        case .director: .director
        case .camera: .camera
        }
    }

    /// Bonjour service types this role browses for on the local network.
    public var browsedServiceTypes: [BonjourServiceType] {
        switch self {
        case .director: [.camera]
        case .camera: [.director]
        }
    }
}
