import Foundation

/// Pure domain policy — decides which switcher tiles may attach a live decoder.
public enum ProgramPreviewVisibilityPolicy: Sendable {
    /// Preview + program tiles render live; idle tiles use placeholder or opt-in JPEG.
    case previewSourceOnly
    /// All connected sources render in tiles (desktop multiview — higher CPU).
    case allConnectedSources

    public static let directorDefault: Self = .previewSourceOnly

    public func allowsLiveTile(
        sourceIsPreview: Bool,
        sourceIsProgram: Bool,
        previewEqualsProgram: Bool
    ) -> Bool {
        switch self {
        case .previewSourceOnly:
            _ = previewEqualsProgram
            return sourceIsPreview || sourceIsProgram
        case .allConnectedSources:
            return true
        }
    }

    public func allowsPreviewMonitorHero(programHeroEnabled: Bool) -> Bool {
        programHeroEnabled
    }

    public func allowsPreviewMonitorGridCell(
        sourceIsPreview: Bool,
        sourceIsProgram: Bool,
        previewEqualsProgram: Bool
    ) -> Bool {
        allowsLiveTile(
            sourceIsPreview: sourceIsPreview,
            sourceIsProgram: sourceIsProgram,
            previewEqualsProgram: previewEqualsProgram
        )
    }

    /// Idle tiles only — preview/program use live decoders.
    public func shouldAttachTileThumbnail(
        sourceIsPreview: Bool,
        sourceIsProgram: Bool,
        previewEqualsProgram: Bool
    ) -> Bool {
        _ = previewEqualsProgram
        if sourceIsPreview || sourceIsProgram { return false }
        return true
    }
}
