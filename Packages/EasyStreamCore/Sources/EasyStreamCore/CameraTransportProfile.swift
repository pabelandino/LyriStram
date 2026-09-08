import Foundation

/// Adaptive LAN camera transport tiers — balances quality vs CPU/heat by switcher role.
public enum CameraTransportProfile: Sendable, Equatable {
    /// Connected but not on preview/program — lowest CPU.
    case standby
    /// Selected as preview on the Director.
    case preview
    /// On program (or preview+program) — highest quality.
    case program

    /// Quality policy received from the Director (cameras) or configured locally (director).
    nonisolated(unsafe) public static var directorQuality: DirectorMonitorQualitySettings = .init()

    public static func forAssignment(_ assignment: CameraSwitcherAssignment) -> CameraTransportProfile {
        webRTCProfile(for: assignment)
    }

    /// LAN encode tier for a switcher role. Preview can prewarm to program resolution while warming the take target.
    public static func webRTCProfile(for assignment: CameraSwitcherAssignment) -> CameraTransportProfile {
        let quality = Self.directorQuality.effectiveSettings()
        switch assignment {
        case .idle:
            return .standby
        case .preview:
            return quality.prefetchTakeTarget ? .program : .preview
        case .program, .previewAndProgram:
            return .program
        }
    }

    public var streamSpec: BroadcastStreamSpec {
        let quality = Self.directorQuality
        switch self {
        case .standby:
            return BroadcastStreamSpec(width: 426, height: 240, frameRate: 8, maxBitrateBps: 350_000)
        case .preview:
            return quality.previewPreset.streamSpec
        case .program:
            return quality.progPreset.streamSpec
        }
    }

    public var width: Int32 {
        streamSpec.width
    }

    public var height: Int32 {
        streamSpec.height
    }

    public var frameRate: Int32 {
        streamSpec.frameRate
    }

    public var maxBitrateBps: Int {
        streamSpec.maxBitrateBps
    }

    public var minBitrateBps: Int {
        max(200_000, maxBitrateBps / 4)
    }
}
