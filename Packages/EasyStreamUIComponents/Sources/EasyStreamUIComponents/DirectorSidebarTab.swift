import Foundation

public enum DirectorSidebarTab: String, CaseIterable, Identifiable, Sendable {
    case cameras
    case library
    case playlists

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .cameras: "Cámaras"
        case .library: "Biblioteca"
        case .playlists: "Playlists"
        }
    }

    public var systemImage: String {
        switch self {
        case .cameras: "video.fill"
        case .library: "photo.on.rectangle.angled"
        case .playlists: "list.bullet.rectangle"
        }
    }

    /// Tabs shown on the left sources rail (library lives on the right rail).
    public static let leftRailTabs: [DirectorSidebarTab] = [.cameras, .playlists]
}
