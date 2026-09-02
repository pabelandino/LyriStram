import WebRTC

/// Platform container surface consumed by `ProgramCrossfadeSession`.
///
/// Two-slot model (director monitor):
/// - `programRenderer` / `outgoingRenderer`: permanent on-air bus (outgoing during transitions).
/// - `incomingRenderer`: preview warmup when idle; incoming layer during transitions.
@MainActor
protocol ProgramCrossfadeHost: AnyObject {
    var programRenderer: RTCVideoRenderer { get }
    var outgoingRenderer: RTCVideoRenderer { get }
    var incomingRenderer: RTCVideoRenderer { get }

    func setCrossfadePresentationMode(idleProgram: Bool, transitioning: Bool, warmingTake: Bool)
    func enterIdleProgramMode(preservingProgramPresentation: Bool, warmingTake: Bool)
    func applyCrossfadeSlots(
        programSlot: ProgramTransitionSlot,
        takeSlot: ProgramTransitionSlot,
        incomingOnProgram: Bool
    )
    /// Hides the on-air layer while the incoming track binds to the hidden program renderer.
    func beginTransitionHandoff()
    /// Reveals the on-air layer and hides the take layer in one step.
    func completeTransitionHandoff()
    func revealTakeLayer()
    func resetTransitionSlotPresentation()
    func resetCrossfadePresentation()
}

extension ProgramCrossfadeHost {
    func finalizeTransitionHandoff() {
        completeTransitionHandoff()
    }

    func resetCrossfadePresentation() {
        resetTransitionSlotPresentation()
    }
}
