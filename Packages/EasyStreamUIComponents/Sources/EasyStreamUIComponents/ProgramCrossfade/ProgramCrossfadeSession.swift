import EasyStreamCore
import WebRTC

/// Unified apply/update logic for UIKit and AppKit coordinators.
///
/// Two-slot model: outgoing always on `programRenderer`, incoming always on `incomingRenderer`.
/// Stack order swaps which layer is visible; a single track commit happens at transition completion.
@MainActor
final class ProgramCrossfadeSession {
    private var programAttached: RTCVideoTrack?
    private var takeAttached: RTCVideoTrack?
    private var lastAppliedSignature: ApplySignature?
    private var transitionActive = false
    private var committedIncomingTrack: RTCVideoTrack?
    private var takeLayerRevealed = false
    private var skipNextIdleAttach = false

    private struct ApplySignature: Equatable {
        let programTrack: ObjectIdentifier?
        let takeTrack: ObjectIdentifier?
        let outgoingTrack: ObjectIdentifier?
        let incomingTrack: ObjectIdentifier?
        let isTransitioning: Bool
        let progressBucket: Int
        let kind: SwitchTransitionKind
        let incomingOnProgram: Bool
    }

    func apply(
        on host: ProgramCrossfadeHost,
        programTrack: RTCVideoTrack?,
        outgoingTrack: RTCVideoTrack?,
        incomingTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        progress: Double,
        kind: SwitchTransitionKind
    ) {
        let takeTrack = isTransitioning ? incomingTrack : warmedTakeTrack(
            programTrack: programTrack,
            takeTrack: incomingTrack
        )

        let engineFrame = isTransitioning
            ? ProgramTransitionEngine.frame(linearProgress: progress, kind: kind)
            : nil
        let incomingOnTop = engineFrame.map {
            Self.shouldRenderIncomingOnTop(frame: $0, progress: progress)
        } ?? false

        let signature = ApplySignature(
            programTrack: programTrack.map(ObjectIdentifier.init),
            takeTrack: takeTrack.map(ObjectIdentifier.init),
            outgoingTrack: outgoingTrack.map(ObjectIdentifier.init),
            incomingTrack: incomingTrack.map(ObjectIdentifier.init),
            isTransitioning: isTransitioning,
            progressBucket: isTransitioning ? Self.progressBucket(progress) : 240,
            kind: kind,
            incomingOnProgram: incomingOnTop
        )
        let needsTransitionCompletion = transitionActive && !isTransitioning
        guard signature != lastAppliedSignature || needsTransitionCompletion else { return }
        lastAppliedSignature = signature

        if isTransitioning, let outgoingTrack, let incomingTrack, let engineFrame {
            applyTransition(
                on: host,
                outgoingTrack: outgoingTrack,
                incomingTrack: incomingTrack,
                engineFrame: engineFrame,
                incomingOnTop: incomingOnTop
            )
            return
        }

        guard let programTrack else {
            applyEmpty(on: host)
            return
        }

        applyProgram(on: host, programTrack: programTrack, takeTrack: takeTrack)
    }

    private static func progressBucket(_ progress: Double) -> Int {
        Int((min(max(progress, 0), 1) * 240).rounded())
    }

    private func warmedTakeTrack(
        programTrack: RTCVideoTrack?,
        takeTrack: RTCVideoTrack?
    ) -> RTCVideoTrack? {
        guard let takeTrack else { return nil }
        guard takeTrack !== programTrack else { return nil }
        return takeTrack
    }

    private func applyTransition(
        on host: ProgramCrossfadeHost,
        outgoingTrack: RTCVideoTrack,
        incomingTrack: RTCVideoTrack,
        engineFrame: ProgramTransitionFrame,
        incomingOnTop: Bool
    ) {
        let isBeginning = !transitionActive

        if isBeginning {
            ProgramCrossfadeRenderer.swapAttach(
                outgoingTrack,
                to: host.outgoingRenderer,
                storage: &programAttached
            )
            ProgramCrossfadeRenderer.swapAttach(
                incomingTrack,
                to: host.incomingRenderer,
                storage: &takeAttached
            )
            committedIncomingTrack = incomingTrack
        }

        host.setCrossfadePresentationMode(idleProgram: false, transitioning: true, warmingTake: false)
        host.applyCrossfadeSlots(
            programSlot: engineFrame.outgoing,
            takeSlot: engineFrame.incoming,
            incomingOnProgram: incomingOnTop
        )

        if !takeLayerRevealed {
            host.revealTakeLayer()
            takeLayerRevealed = true
        }

        if !isBeginning {
            ProgramCrossfadeRenderer.swapAttach(
                outgoingTrack,
                to: host.outgoingRenderer,
                storage: &programAttached
            )
            ProgramCrossfadeRenderer.swapAttach(
                incomingTrack,
                to: host.incomingRenderer,
                storage: &takeAttached
            )
        }

        transitionActive = true
    }

    private static func shouldRenderIncomingOnTop(
        frame: ProgramTransitionFrame,
        progress: Double
    ) -> Bool {
        if progress >= 0.95 { return true }
        switch frame.presentationMode {
        case .opacityOnly:
            return frame.incoming.opacity >= frame.outgoing.opacity
        case .spatial:
            if frame.incoming.opacity > frame.outgoing.opacity + 0.001 {
                return true
            }
            return false
        }
    }

    private func applyProgram(
        on host: ProgramCrossfadeHost,
        programTrack: RTCVideoTrack,
        takeTrack: RTCVideoTrack?
    ) {
        if transitionActive {
            performTransitionHandoff(on: host, incomingTrack: committedIncomingTrack)
            return
        }

        if skipNextIdleAttach {
            skipNextIdleAttach = false
            finalizeIdleAfterHandoff(on: host, takeTrack: takeTrack)
            return
        }

        if programAttached !== programTrack {
            ProgramCrossfadeRenderer.swapAttach(
                programTrack,
                to: host.programRenderer,
                storage: &programAttached
            )
        }

        if let takeTrack {
            ProgramCrossfadeRenderer.swapAttach(
                takeTrack,
                to: host.incomingRenderer,
                storage: &takeAttached
            )
            host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: true)
        } else {
            if takeAttached != nil {
                ProgramCrossfadeRenderer.detachAndClear(
                    host.incomingRenderer,
                    storage: &takeAttached
                )
            }
            host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
        }
    }

    private func performTransitionHandoff(
        on host: ProgramCrossfadeHost,
        incomingTrack: RTCVideoTrack?
    ) {
        transitionActive = false
        takeLayerRevealed = false

        guard let incomingTrack else {
            host.completeTransitionHandoff()
            committedIncomingTrack = nil
            host.enterIdleProgramMode(preservingProgramPresentation: true, warmingTake: false)
            return
        }

        host.beginTransitionHandoff()

        if let outgoing = programAttached, !Self.tracksMatch(outgoing, incomingTrack) {
            outgoing.remove(host.programRenderer)
            if programAttached === outgoing {
                programAttached = nil
            }
        }
        ProgramCrossfadeRenderer.swapAttach(
            incomingTrack,
            to: host.programRenderer,
            storage: &programAttached
        )

        host.completeTransitionHandoff()

        if let takeTrack = takeAttached {
            if takeTrack !== incomingTrack {
                takeTrack.remove(host.incomingRenderer)
            }
            takeAttached = nil
            ProgramCrossfadeRenderer.clearFrame(in: host.incomingRenderer)
        }

        committedIncomingTrack = nil
        skipNextIdleAttach = true
        host.enterIdleProgramMode(preservingProgramPresentation: true, warmingTake: false)
    }

    private func finalizeIdleAfterHandoff(
        on host: ProgramCrossfadeHost,
        takeTrack: RTCVideoTrack?
    ) {
        if let takeTrack {
            ProgramCrossfadeRenderer.swapAttach(
                takeTrack,
                to: host.incomingRenderer,
                storage: &takeAttached
            )
            host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: true)
        } else {
            if takeAttached != nil {
                ProgramCrossfadeRenderer.detachAndClear(
                    host.incomingRenderer,
                    storage: &takeAttached
                )
            }
            host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
        }
    }

    private func applyEmpty(on host: ProgramCrossfadeHost) {
        transitionActive = false
        takeLayerRevealed = false
        skipNextIdleAttach = false
        committedIncomingTrack = nil
        ProgramCrossfadeRenderer.detachAndClear(host.incomingRenderer, storage: &takeAttached)
        ProgramCrossfadeRenderer.detachAndClear(host.programRenderer, storage: &programAttached)
        host.resetCrossfadePresentation()
        host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
    }

    private static func tracksMatch(_ lhs: RTCVideoTrack?, _ rhs: RTCVideoTrack?) -> Bool {
        guard let lhs, let rhs else { return lhs == nil && rhs == nil }
        if lhs === rhs { return true }
        return lhs.trackId == rhs.trackId
    }
}
