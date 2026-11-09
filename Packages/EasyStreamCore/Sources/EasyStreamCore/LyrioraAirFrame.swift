import Foundation

/// One live frame from Lyriora. Newline-delimited JSON on the air socket.
public struct LyrioraAirFrame: Codable, Equatable, Sendable {
    public var revision: Int
    public var active: Bool
    public var content: LyrioraAirContent
    public var title: String
    public var reference: String
    public var body: String

    public init(
        revision: Int,
        active: Bool,
        content: LyrioraAirContent,
        title: String,
        reference: String,
        body: String
    ) {
        self.revision = revision
        self.active = active
        self.content = content
        self.title = title
        self.reference = reference
        self.body = body
    }

    public static let clear = LyrioraAirFrame(
        revision: 0,
        active: false,
        content: .clear,
        title: "",
        reference: "",
        body: ""
    )

    /// Song title, or the verse reference when the frame is scripture.
    public var headline: String {
        switch content {
        case .bible:
            let reference = reference.trimmingCharacters(in: .whitespacesAndNewlines)
            if !reference.isEmpty { return reference }
            return title.trimmingCharacters(in: .whitespacesAndNewlines)
        case .lyric:
            return title.trimmingCharacters(in: .whitespacesAndNewlines)
        case .clear:
            return ""
        }
    }

    public var verseBody: String {
        body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var hasText: Bool {
        content != .clear && !verseBody.isEmpty
    }
}
