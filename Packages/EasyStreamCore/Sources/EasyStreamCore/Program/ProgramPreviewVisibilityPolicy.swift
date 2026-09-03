import Foundation

/// Pure domain policy — decides which switcher tiles may attach a live decoder.
public enum ProgramPreviewVisibilityPolicy: Sendable {
    /// Only the selected preview source renders live video in tiles (program uses PROG monitor).
    case previewSourceOnly
    /// All connected sources render in tiles (desktop multiview — higher CPU).
    case allConnectedSources

    public static let directorDefault: Self = .previewSourceOnly

    public func allowsLiveTile(
        sourceIsPreview: Bool,
        previewEqualsProgram: Bool
    ) -> Bool {
        switch self {
        case .previewSourceOnly:
            return sourceIsPreview && !previewEqualsProgram
        case .allConnectedSources:
            return true
        }
    }

    public func allowsPreviewMonitorHero(programHeroEnabled: Bool) -> Bool {
        switch self {
        case .previewSourceOnly:
            return false
        case .allConnectedSources:
            return programHeroEnabled
        }
    }

    public func allowsPreviewMonitorGridCell(
        sourceIsPreview: Bool,
        previewEqualsProgram: Bool
    ) -> Bool {
        allowsLiveTile(
            sourceIsPreview: sourceIsPreview,
            previewEqualsProgram: previewEqualsProgram
        )
    }
}
