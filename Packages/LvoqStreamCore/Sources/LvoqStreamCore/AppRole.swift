import Foundation

/// Application role selected at launch.
public enum AppRole: String, Codable, Sendable, CaseIterable, Identifiable {
    case director
    case camera

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .director: BundleLocalization.string("role.director.title")
        case .camera: BundleLocalization.string("role.camera.title")
        }
    }

    public var subtitle: String {
        switch self {
        case .director: BundleLocalization.string("role.director.subtitle")
        case .camera: BundleLocalization.string("role.camera.subtitle")
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
    /// Intercom uses its own browser in `TeamIntercomService`; browsing it here would
    /// overwrite signaling endpoints that share the same device ID in TXT records.
    public var browsedServiceTypes: [BonjourServiceType] {
        switch self {
        case .director: [.camera]
        case .camera: [.director]
        }
    }

    /// Whether this role participates in team intercom on the local network.
    public var participatesInIntercom: Bool { true }
}
