import Foundation

/// Normalized timeline input — always 0…1 linear wall-clock progress from the view model.
typealias LinearProgress = Double

/// Easing curves applied inside individual effects (opacity vs spatial motion can differ).
enum TransitionCurve: Sendable {
    case linear
    case smoothStep
    case easeInOutCubic

    func evaluate(_ progress: LinearProgress) -> Double {
        let x = min(max(progress, 0), 1)
        switch self {
        case .linear:
            return x
        case .smoothStep:
            return x * x * (3 - 2 * x)
        case .easeInOutCubic:
            if x < 0.5 {
                return 4 * x * x * x
            }
            let shifted = -2 * x + 2
            return 1 - (shifted * shifted * shifted) / 2
        }
    }
}

enum TransitionCurveProfile {
    /// Crossfades and dips — perceptually smooth opacity blends.
    static let opacity = TransitionCurve.smoothStep
    /// Wipe / slide / zoom — linear so the duration slider matches perceived motion speed.
    static let spatial = TransitionCurve.linear
    /// Zoom scale/opacity blend — slightly softer than linear without compressing the timeline.
    static let zoomBlend = TransitionCurve.easeInOutCubic
}
