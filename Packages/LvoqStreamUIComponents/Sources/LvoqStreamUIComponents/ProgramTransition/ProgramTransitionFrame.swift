import Foundation

/// Visual state for one dual-slot layer (outgoing bottom / incoming top).
struct ProgramTransitionSlot: Equatable {
    var opacity: Double
    /// Horizontal offset as a fraction of view width (positive moves right).
    var offsetX: Double
    var scale: Double
    /// Left-to-right reveal mask (0 hidden, 1 full). Nil = no mask.
    var reveal: Double?

    static let hidden = ProgramTransitionSlot(opacity: 0, offsetX: 0, scale: 1, reveal: nil)

    static func visible(
        opacity: Double = 1,
        offsetX: Double = 0,
        scale: Double = 1,
        reveal: Double? = nil
    ) -> ProgramTransitionSlot {
        ProgramTransitionSlot(opacity: opacity, offsetX: offsetX, scale: scale, reveal: reveal)
    }

    var usesSpatialPresentation: Bool {
        if reveal != nil { return true }
        if offsetX != 0 { return true }
        if scale != 1 { return true }
        return false
    }
}

/// Renderer hints derived from the effect — keeps slot wiring free of per-kind switches.
struct ProgramTransitionLifecycle: Equatable {
    var attachesIncoming: Bool
    var detachesOutgoing: Bool
    var commitsIncomingHandoff: Bool

    static let cut = ProgramTransitionLifecycle(
        attachesIncoming: true,
        detachesOutgoing: true,
        commitsIncomingHandoff: true
    )
}

/// How the renderer applies slot transforms for this frame.
enum ProgramTransitionPresentationMode: Equatable {
    case opacityOnly
    case spatial
}

/// Full per-frame output consumed by `ProgramCrossfadeVideoView`.
struct ProgramTransitionFrame: Equatable {
    var outgoing: ProgramTransitionSlot
    var incoming: ProgramTransitionSlot
    var lifecycle: ProgramTransitionLifecycle
    var presentationMode: ProgramTransitionPresentationMode

    var usesVisualTransform: Bool {
        presentationMode == .spatial
    }

    static let cutIncoming = ProgramTransitionFrame(
        outgoing: .hidden,
        incoming: .visible(),
        lifecycle: .cut,
        presentationMode: .opacityOnly
    )
}

enum ProgramTransitionLifecycleRules {
    static func opacityCrossfade(
        linearProgress: LinearProgress,
        outgoingOpacity: Double,
        incomingOpacity: Double
    ) -> ProgramTransitionLifecycle {
        ProgramTransitionLifecycle(
            attachesIncoming: true,
            detachesOutgoing: linearProgress >= 0.999,
            commitsIncomingHandoff: linearProgress >= 0.95 || incomingOpacity >= 0.95
        )
    }

    static func spatial(
        linearProgress: LinearProgress,
        motionProgress: Double,
        attachThreshold: Double = 0,
        completeThreshold: Double = 0.95,
        detachOutgoingThreshold: Double = 0.999
    ) -> ProgramTransitionLifecycle {
        ProgramTransitionLifecycle(
            attachesIncoming: true,
            detachesOutgoing: linearProgress >= detachOutgoingThreshold || motionProgress >= detachOutgoingThreshold,
            commitsIncomingHandoff: linearProgress >= completeThreshold || motionProgress >= completeThreshold
        )
    }
}
