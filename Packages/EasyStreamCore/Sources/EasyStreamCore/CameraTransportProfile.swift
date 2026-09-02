import Foundation

/// Adaptive LAN camera transport tiers — balances quality vs CPU/heat by switcher role.
public enum CameraTransportProfile: Sendable, Equatable {
    /// Connected but not on preview/program — lowest CPU.
    case standby
    /// Selected as preview on the Director.
    case preview
    /// On program (or preview+program) — highest quality.
    case program

    public static func forAssignment(_ assignment: CameraSwitcherAssignment) -> CameraTransportProfile {
        switch assignment {
        case .idle:
            return .standby
        case .preview:
            return .preview
        case .program, .previewAndProgram:
            return .program
        }
    }

    public var width: Int32 {
#if os(iOS)
        switch self {
        case .standby: 480
        case .preview: 640
        case .program: 960
        }
#else
        switch self {
        case .standby: 640
        case .preview: 1_280
        case .program: 1_920
        }
#endif
    }

    public var height: Int32 {
#if os(iOS)
        switch self {
        case .standby: 360
        case .preview: 480
        case .program: 540
        }
#else
        switch self {
        case .standby: 360
        case .preview: 720
        case .program: 1_080
        }
#endif
    }

    public var frameRate: Int32 {
#if os(iOS)
        switch self {
        case .standby: 12
        case .preview: 20
        case .program: 24
        }
#else
        switch self {
        case .standby: 15
        case .preview: 24
        case .program: 30
        }
#endif
    }

    public var maxBitrateBps: Int {
#if os(iOS)
        switch self {
        case .standby: 450_000
        case .preview: 900_000
        case .program: 1_800_000
        }
#else
        switch self {
        case .standby: 800_000
        case .preview: 2_500_000
        case .program: 5_000_000
        }
#endif
    }

    public var minBitrateBps: Int {
        max(200_000, maxBitrateBps / 4)
    }
}
