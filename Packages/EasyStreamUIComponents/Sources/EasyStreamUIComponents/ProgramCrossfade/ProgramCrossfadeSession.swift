import EasyStreamCore
import WebRTC

/// Single source of truth for the three-lane Metal program bus (program / outgoing / incoming).
///
/// **Multi-device (N cameras):** logic is keyed by `CameraSourceID` / WebRTC `trackId`, not device count.
/// At any moment exactly one source is **program**, one **preview** (warmed on incoming), all others **idle**.
/// Cuts and preview changes behave the same whether 2 or 20 sources are connected.
///
/// Phases:
/// - **empty** — no tracks attached
/// - **offAirWarm** — preview decoded on incoming (hidden); PROG monitor stays black until take
/// - **onAir** — program on program lane; next preview warming on incoming (hidden)
/// - **transitioning** — outgoing + incoming lanes; compositor blend mode
@MainActor
final class ProgramBusController {
    private enum Phase: Equatable {
        case empty
        case offAirWarm
        case onAir
        case transitioning
    }

    private struct Snapshot: Equatable {
        let programTrackId: String?
        let warmTrackId: String?
        let outgoingTrackId: String?
        let incomingTrackId: String?
        let isTransitioning: Bool
        let progressBucket: Int
        let kind: SwitchTransitionKind
    }

    private var phase: Phase = .empty
    private var attachedProgram: RTCVideoTrack?
    private var attachedOutgoing: RTCVideoTrack?
    private var attachedIncoming: RTCVideoTrack?
    private var lastSnapshot: Snapshot?

    func apply(
        on host: ProgramCrossfadeHost,
        programTrack: RTCVideoTrack?,
        outgoingTrack: RTCVideoTrack?,
        incomingTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        progress: Double,
        kind: SwitchTransitionKind
    ) {
        let warmTrack = isTransitioning
            ? nil
            : warmedPreviewTrack(program: programTrack, preview: incomingTrack)

        let snapshot = Snapshot(
            programTrackId: trackId(programTrack),
            warmTrackId: trackId(warmTrack),
            outgoingTrackId: trackId(outgoingTrack),
            incomingTrackId: trackId(incomingTrack),
            isTransitioning: isTransitioning,
            progressBucket: isTransitioning ? Self.progressBucket(progress) : 240,
            kind: kind
        )

        let leavingTransition = phase == .transitioning && !isTransitioning
        guard snapshot != lastSnapshot || leavingTransition else {
            let rebinding = refreshTrackReferences(
                on: host,
                programTrack: programTrack,
                warmTrack: warmTrack,
                outgoingTrack: outgoingTrack,
                incomingTrack: incomingTrack
            )
            if rebinding {
                ProgramBusTrace.event(
                    "controller refresh-only rebinding prog=\(ProgramBusTrace.shortTrackId(snapshot.programTrackId)) in=\(ProgramBusTrace.shortTrackId(snapshot.incomingTrackId))"
                )
            }
            return
        }

        ProgramBusTrace.event(
            "controller apply phase=\(phaseLabel) prog=\(ProgramBusTrace.shortTrackId(snapshot.programTrackId)) warm=\(ProgramBusTrace.shortTrackId(snapshot.warmTrackId)) in=\(ProgramBusTrace.shortTrackId(snapshot.incomingTrackId)) transitioning=\(isTransitioning)"
        )

        if isTransitioning, let outgoingTrack, let incomingTrack {
            applyTransitioning(
                on: host,
                outgoing: outgoingTrack,
                incoming: incomingTrack,
                progress: progress,
                kind: kind
            )
            phase = .transitioning
            lastSnapshot = snapshot
            return
        }

        if phase == .transitioning {
            finishTransition(
                on: host,
                programTrack: programTrack,
                warmTrack: warmTrack,
                incomingHint: incomingTrack
            )
            phase = programTrack != nil ? .onAir : (warmTrack != nil ? .offAirWarm : .empty)
            lastSnapshot = snapshot
            return
        }

        if let programTrack {
            applyOnAir(
                on: host,
                program: programTrack,
                warm: warmTrack,
                incomingHint: incomingTrack
            )
            phase = .onAir
        } else if let warmTrack {
            applyOffAir(on: host, warm: warmTrack)
            phase = .offAirWarm
        } else {
            applyEmpty(on: host)
            phase = .empty
        }

        lastSnapshot = snapshot
    }

    // MARK: - Transitioning

    private func applyTransitioning(
        on host: ProgramCrossfadeHost,
        outgoing: RTCVideoTrack,
        incoming: RTCVideoTrack,
        progress: Double,
        kind: SwitchTransitionKind
    ) {
        if phase != .transitioning {
            detachTrack(&attachedProgram, from: host.programRenderer)
            host.clearMetalTransitionFrames()
        }

        attachTrack(outgoing, to: host.outgoingRenderer, storage: &attachedOutgoing)
        attachTrack(incoming, to: host.incomingRenderer, storage: &attachedIncoming)

        let engineFrame = ProgramTransitionEngine.frame(linearProgress: progress, kind: kind)
        host.applyTransitionFrame(engineFrame, incomingOnProgram: false)
    }

    private func finishTransition(
        on host: ProgramCrossfadeHost,
        programTrack: RTCVideoTrack?,
        warmTrack: RTCVideoTrack?,
        incomingHint: RTCVideoTrack?
    ) {
        host.completeTransitionHandoff()
        detachTrack(&attachedOutgoing, from: host.outgoingRenderer)
        host.clearMetalTransitionFrames()

        if let programTrack {
            syncIncomingLane(on: host, incomingHint: incomingHint)

            if tracksMatch(attachedIncoming, programTrack) {
                performInstantCut(on: host, program: programTrack)
            } else {
                rebindProgram(on: host, program: programTrack)
            }
            attachWarmTrack(warmTrack, program: programTrack, on: host)
            host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
        } else if let warmTrack {
            applyOffAir(on: host, warm: warmTrack)
        } else {
            applyEmpty(on: host)
        }
    }

    // MARK: - On-air idle

    private func applyOnAir(
        on host: ProgramCrossfadeHost,
        program: RTCVideoTrack,
        warm: RTCVideoTrack?,
        incomingHint: RTCVideoTrack?
    ) {
        syncIncomingLane(on: host, incomingHint: incomingHint)

        if tracksMatch(attachedIncoming, program) {
            performInstantCut(on: host, program: program)
        } else if !tracksMatch(attachedProgram, program) {
            rebindProgram(on: host, program: program)
        }

        attachWarmTrack(warm, program: program, on: host)
        host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
    }

    /// Keeps the incoming lane subscribed to the hinted track (take target or warmed preview).
    private func syncIncomingLane(
        on host: ProgramCrossfadeHost,
        incomingHint: RTCVideoTrack?
    ) {
        guard let incomingHint else { return }
        attachTrack(incomingHint, to: host.incomingRenderer, storage: &attachedIncoming)
    }

    // MARK: - Off-air warm (incoming decodes hidden; PROG monitor stays black until take)

    private func applyOffAir(on host: ProgramCrossfadeHost, warm: RTCVideoTrack) {
        if phase == .onAir {
            detachTrack(&attachedProgram, from: host.programRenderer)
            host.clearProgramVideoFrame()
        }
        detachTrack(&attachedOutgoing, from: host.outgoingRenderer)

        attachTrack(warm, to: host.incomingRenderer, storage: &attachedIncoming)
        host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
    }

    // MARK: - Empty

    private func applyEmpty(on host: ProgramCrossfadeHost) {
        detachTrack(&attachedIncoming, from: host.incomingRenderer)
        detachTrack(&attachedOutgoing, from: host.outgoingRenderer)
        detachTrack(&attachedProgram, from: host.programRenderer)
        host.clearMetalVideoFrames()
        host.resetCrossfadePresentation()
        host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
    }

    // MARK: - Cut / rebind

    private func performInstantCut(on host: ProgramCrossfadeHost, program: RTCVideoTrack) {
        guard tracksMatch(attachedIncoming, program) else {
            ProgramBusTrace.event(
                "controller performInstantCut fallback rebind trackId=\(ProgramBusTrace.shortTrackId(program.trackId)) incomingMatch=false"
            )
            rebindProgram(on: host, program: program)
            return
        }

        ProgramBusTrace.event(
            "controller performInstantCut trackId=\(ProgramBusTrace.shortTrackId(program.trackId))"
        )

        host.promoteIncomingFrameToProgram()

        attachedIncoming?.remove(host.incomingRenderer)
        if !tracksMatch(attachedProgram, program) {
            attachedProgram?.remove(host.programRenderer)
            program.add(host.programRenderer)
        }
        attachedProgram = program
        attachedIncoming = nil

        ProgramCrossfadeRenderer.clearFrame(in: host.incomingRenderer)
        host.clearMetalTransitionFrames()
        host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
    }

    private func rebindProgram(on host: ProgramCrossfadeHost, program: RTCVideoTrack) {
        ProgramBusTrace.event(
            "controller rebindProgram trackId=\(ProgramBusTrace.shortTrackId(program.trackId))"
        )
        detachTrack(&attachedOutgoing, from: host.outgoingRenderer)
        detachTrack(&attachedIncoming, from: host.incomingRenderer)
        host.clearMetalTransitionFrames()

        if attachedProgram != nil {
            ProgramCrossfadeRenderer.detachAndClear(host.programRenderer, storage: &attachedProgram)
        }

        ProgramCrossfadeRenderer.forceAttach(
            program,
            to: host.programRenderer,
            storage: &attachedProgram
        )
    }

    // MARK: - Attach helpers

    private func attachWarmTrack(
        _ warm: RTCVideoTrack?,
        program: RTCVideoTrack,
        on host: ProgramCrossfadeHost
    ) {
        guard let warm, !tracksMatch(warm, program) else {
            detachTrack(&attachedIncoming, from: host.incomingRenderer)
            return
        }
        attachTrack(warm, to: host.incomingRenderer, storage: &attachedIncoming)
    }

    private func attachTrack(
        _ track: RTCVideoTrack,
        to renderer: RTCVideoRenderer,
        storage: inout RTCVideoTrack?
    ) {
        ProgramCrossfadeRenderer.swapAttach(track, to: renderer, storage: &storage)
    }

    private func detachTrack(
        _ storage: inout RTCVideoTrack?,
        from renderer: RTCVideoRenderer
    ) {
        guard storage != nil else { return }
        ProgramCrossfadeRenderer.detachAndClear(renderer, storage: &storage)
    }

    // MARK: - Utilities

    private func warmedPreviewTrack(
        program: RTCVideoTrack?,
        preview: RTCVideoTrack?
    ) -> RTCVideoTrack? {
        guard let preview else { return nil }
        guard !tracksMatch(preview, program) else { return nil }
        return preview
    }

    private static func progressBucket(_ progress: Double) -> Int {
        Int((min(max(progress, 0), 1) * 240).rounded())
    }

    private func trackId(_ track: RTCVideoTrack?) -> String? {
        track?.trackId
    }

    /// Re-subscribes renderers when WebRTC replaces a track object with the same `trackId`.
    @discardableResult
    private func refreshTrackReferences(
        on host: ProgramCrossfadeHost,
        programTrack: RTCVideoTrack?,
        warmTrack: RTCVideoTrack?,
        outgoingTrack: RTCVideoTrack?,
        incomingTrack: RTCVideoTrack?
    ) -> Bool {
        var rebinding = false
        if let programTrack, tracksMatch(attachedProgram, programTrack), attachedProgram !== programTrack {
            rebinding = true
            ProgramCrossfadeRenderer.swapAttach(
                programTrack,
                to: host.programRenderer,
                storage: &attachedProgram
            )
        }
        if let outgoingTrack, tracksMatch(attachedOutgoing, outgoingTrack), attachedOutgoing !== outgoingTrack {
            rebinding = true
            ProgramCrossfadeRenderer.swapAttach(
                outgoingTrack,
                to: host.outgoingRenderer,
                storage: &attachedOutgoing
            )
        }
        let incomingHint = warmTrack ?? incomingTrack
        if let incomingHint, tracksMatch(attachedIncoming, incomingHint), attachedIncoming !== incomingHint {
            rebinding = true
            ProgramCrossfadeRenderer.swapAttach(
                incomingHint,
                to: host.incomingRenderer,
                storage: &attachedIncoming
            )
        }
        return rebinding
    }

    private var phaseLabel: String {
        switch phase {
        case .empty: "empty"
        case .offAirWarm: "offAirWarm"
        case .onAir: "onAir"
        case .transitioning: "transitioning"
        }
    }

    private func tracksMatch(_ lhs: RTCVideoTrack?, _ rhs: RTCVideoTrack?) -> Bool {
        guard let lhs, let rhs else { return lhs == nil && rhs == nil }
        if lhs === rhs { return true }
        return lhs.trackId == rhs.trackId
    }
}

/// Backward-compatible alias for coordinators that still reference the old session type.
typealias ProgramCrossfadeSession = ProgramBusController
