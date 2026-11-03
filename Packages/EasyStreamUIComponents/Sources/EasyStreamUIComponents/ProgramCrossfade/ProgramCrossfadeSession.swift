import EasyStreamCore
import WebRTC
import EasyStreamVideoPipeline

/// Single source of truth for the three-lane Metal program bus (program / outgoing / incoming).
///
/// **Multi-device (N cameras):** logic is keyed by `CameraSourceID` / WebRTC `trackId`, not device count.
/// At any moment exactly one source is **program**, one **preview** (warmed on incoming), all others **idle**.
/// Cuts and preview changes behave the same whether 2 or 20 sources are connected.
///
/// Phases:
/// - **empty** — no tracks attached
/// - **offAirWarm** — preview decoded on incoming; PROG monitor mirrors preview until first take
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
        let programTrackKey: String?
        let warmTrackKey: String?
        let outgoingTrackKey: String?
        let incomingTrackKey: String?
        let isTransitioning: Bool
        let progressBucket: Int
        let kind: SwitchTransitionKind
        let offAirPreviewVisibleOnProgramMonitor: Bool
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
        kind: SwitchTransitionKind,
        offAirPreviewVisibleOnProgramMonitor: Bool = false
    ) {
        let warmTrack = isTransitioning
            ? nil
            : warmedPreviewTrack(program: programTrack, preview: incomingTrack)

        let snapshot = Snapshot(
            programTrackKey: trackInstanceKey(programTrack),
            warmTrackKey: trackInstanceKey(warmTrack),
            outgoingTrackKey: trackInstanceKey(outgoingTrack),
            incomingTrackKey: trackInstanceKey(incomingTrack),
            isTransitioning: isTransitioning,
            progressBucket: isTransitioning ? Self.progressBucket(progress) : 240,
            kind: kind,
            offAirPreviewVisibleOnProgramMonitor: offAirPreviewVisibleOnProgramMonitor
        )

        let leavingTransition = phase == .transitioning && !isTransitioning
        guard snapshot != lastSnapshot || leavingTransition else {
            routeDisplay(
                on: host,
                onAir: isTransitioning ? nil : programTrack,
                incoming: isTransitioning ? incomingTrack : warmTrack,
                outgoing: isTransitioning ? outgoingTrack : nil
            )
            return
        }

        ProgramBusTrace.event(
            "controller apply phase=\(phaseLabel) prog=\(snapshot.programTrackKey ?? "nil") warm=\(snapshot.warmTrackKey ?? "nil") in=\(snapshot.incomingTrackKey ?? "nil") transitioning=\(isTransitioning)"
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
                warmTrack: warmTrack
            )
            phase = programTrack != nil ? .onAir : (warmTrack != nil ? .offAirWarm : .empty)
            lastSnapshot = snapshot
            return
        }

        if let programTrack {
            applyOnAir(
                on: host,
                program: programTrack,
                warm: warmTrack
            )
            phase = .onAir
        } else if let warmTrack {
            applyOffAir(
                on: host,
                warm: warmTrack,
                visibleOnProgramMonitor: offAirPreviewVisibleOnProgramMonitor
            )
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
        routeDisplay(on: host, onAir: nil, incoming: incoming, outgoing: outgoing)

        let engineFrame = ProgramTransitionEngine.frame(linearProgress: progress, kind: kind)
        host.applyTransitionFrame(engineFrame, incomingOnProgram: false)
    }

    private func finishTransition(
        on host: ProgramCrossfadeHost,
        programTrack: RTCVideoTrack?,
        warmTrack: RTCVideoTrack?
    ) {
        host.completeTransitionHandoff()
        host.clearMetalTransitionFrames()

        if let programTrack {
            routeDisplay(on: host, onAir: programTrack, incoming: warmTrack, outgoing: nil)
            host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
        } else if let warmTrack {
            applyOffAir(on: host, warm: warmTrack, visibleOnProgramMonitor: false)
        } else {
            applyEmpty(on: host)
        }
    }

    // MARK: - On-air idle

    private func applyOnAir(
        on host: ProgramCrossfadeHost,
        program: RTCVideoTrack,
        warm: RTCVideoTrack?
    ) {
        routeDisplay(on: host, onAir: program, incoming: warm, outgoing: nil)
        host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
    }

    // MARK: - Off-air warm (iOS: hidden until take; Android Expo: optional PROG mirror)

    private func applyOffAir(
        on host: ProgramCrossfadeHost,
        warm: RTCVideoTrack,
        visibleOnProgramMonitor: Bool
    ) {
        routeDisplay(
            on: host,
            onAir: visibleOnProgramMonitor ? warm : nil,
            incoming: warm,
            outgoing: nil
        )
        host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: visibleOnProgramMonitor)
    }

    // MARK: - Empty

    private func applyEmpty(on host: ProgramCrossfadeHost) {
        routeDisplay(on: host, onAir: nil, incoming: nil, outgoing: nil)
        host.clearMetalVideoFrames()
        host.resetCrossfadePresentation()
        host.enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
    }

    /// Drops the extra program/incoming/outgoing sinks once. Cuts must not rebind those renderers.
    private var releasedMetalRenderers = false

    private func releaseMetalRenderersIfNeeded(on host: ProgramCrossfadeHost) {
        guard !releasedMetalRenderers else { return }
        releasedMetalRenderers = true
        detachTrack(&attachedProgram, from: host.programRenderer)
        detachTrack(&attachedOutgoing, from: host.outgoingRenderer)
        detachTrack(&attachedIncoming, from: host.incomingRenderer)
    }

    private func routeDisplay(
        on host: ProgramCrossfadeHost,
        onAir: RTCVideoTrack?,
        incoming: RTCVideoTrack?,
        outgoing: RTCVideoTrack?
    ) {
        releaseMetalRenderersIfNeeded(on: host)
        DirectorDecodedSignalCache.shared.setDisplayTracks(
            onAir: onAir,
            incoming: incoming,
            outgoing: outgoing
        )
    }

    // MARK: - Attach helpers

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

    private var phaseLabel: String {
        switch phase {
        case .empty: "empty"
        case .offAirWarm: "offAirWarm"
        case .onAir: "onAir"
        case .transitioning: "transitioning"
        }
    }

    private func tracksMatch(_ lhs: RTCVideoTrack?, _ rhs: RTCVideoTrack?) -> Bool {
        lhs === rhs
    }

    /// WebRTC reuses `trackId` across peer connections (`easystream-video`) — key by object identity.
    private func trackInstanceKey(_ track: RTCVideoTrack?) -> String? {
        guard let track else { return nil }
        return String(ObjectIdentifier(track).hashValue)
    }
}

/// Backward-compatible alias for coordinators that still reference the old session type.
typealias ProgramCrossfadeSession = ProgramBusController
