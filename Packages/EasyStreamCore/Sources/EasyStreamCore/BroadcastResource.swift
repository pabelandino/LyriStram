import Foundation

public enum BroadcastResourceKind: String, Codable, Sendable, CaseIterable {
    case image
    case video
    case widget

    public var title: String {
        switch self {
        case .image: "Imágenes"
        case .video: "Videos"
        case .widget: "Widgets"
        }
    }

    public var systemImage: String {
        switch self {
        case .image: "photo.on.rectangle.angled"
        case .video: "film.stack"
        case .widget: "rectangle.3.group"
        }
    }
}

public struct BroadcastResource: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let kind: BroadcastResourceKind
    public var fileName: String
    public var displayName: String?
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        kind: BroadcastResourceKind,
        fileName: String,
        displayName: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.kind = kind
        self.fileName = fileName
        self.displayName = displayName
        self.createdAt = createdAt
    }

    public var listLabel: String {
        let trimmedDisplayName = displayName?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmedDisplayName, !trimmedDisplayName.isEmpty {
            return trimmedDisplayName
        }
        return (fileName as NSString).deletingPathExtension
    }
}
