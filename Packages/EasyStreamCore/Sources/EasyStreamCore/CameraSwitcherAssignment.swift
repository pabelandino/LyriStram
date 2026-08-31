import Foundation

/// Tells a camera client how the Director is using it (preview / program / idle).
public enum CameraSwitcherAssignment: String, Codable, Sendable, Equatable {
    case idle
    case preview
    case program
    case previewAndProgram

    public var isActive: Bool {
        self != .idle
    }

    public var displayName: String {
        switch self {
        case .idle: "En espera"
        case .preview: BroadcastTerminology.previewName
        case .program: BroadcastTerminology.programName
        case .previewAndProgram: "\(BroadcastTerminology.previewShort) + \(BroadcastTerminology.programShort)"
        }
    }
}
