import Foundation

public enum BroadcastPlaylistKind: String, Codable, CaseIterable, Sendable {
    case image
    case video
    case widget
    case mixed

    public var title: String {
        switch self {
        case .image: "Imágenes"
        case .video: "Videos"
        case .widget: "Widgets"
        case .mixed: "Mixta"
        }
    }

    public var systemImage: String {
        switch self {
        case .image: "photo.on.rectangle.angled"
        case .video: "film.stack"
        case .widget: "rectangle.3.group"
        case .mixed: "list.bullet.rectangle"
        }
    }
}

public struct BroadcastPlaylist: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var kind: BroadcastPlaylistKind
    public var itemIDs: [UUID]
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        kind: BroadcastPlaylistKind,
        itemIDs: [UUID] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.itemIDs = itemIDs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public func matchesSearch(_ query: String) -> Bool {
        BroadcastMediaSearch.matches(query, in: name)
    }
}
