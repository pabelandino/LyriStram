import CoreVideo
import EasyStreamCore
import Foundation
import WebRTC

/// Background bank of already-decoded camera signals.
///
/// Each connected camera keeps one sink for the life of the track. Preview tiles and the program
/// monitor only choose which cached signal to show — they do not start a new encode or decode.
public final class DirectorDecodedSignalCache: @unchecked Sendable {
    public static let shared = DirectorDecodedSignalCache()

    private let lock = NSLock()
    private var sinks: [CameraSourceID: SignalSink] = [:]
    private var tracks: [CameraSourceID: RTCVideoTrack] = [:]
    private var liveSelection: CameraSourceID?
    private var onAirTrack: RTCVideoTrack?
    private var incomingTrack: RTCVideoTrack?
    private var outgoingTrack: RTCVideoTrack?

    private init() {}

    /// Attach a permanent decoder sink to every connected track. Detach only when the camera leaves.
    public func sync(sources: [CameraSourceID: RTCVideoTrack?]) {
        lock.lock()
        let previous = tracks
        var next: [CameraSourceID: RTCVideoTrack] = [:]
        for (sourceID, track) in sources {
            guard let track else { continue }
            next[sourceID] = track
        }
        let removed = Set(previous.keys).subtracting(next.keys)
        let addedOrReplaced = next.filter { previous[$0.key] !== $0.value }
        tracks = next
        lock.unlock()

        for sourceID in removed {
            detach(sourceID)
        }
        for (sourceID, track) in addedOrReplaced {
            attach(sourceID: sourceID, track: track)
        }
    }

    /// Program (or off-air preview) points at a signal that is already in the bank.
    public func setLiveSelection(_ sourceID: CameraSourceID?) {
        lock.lock()
        liveSelection = sourceID
        onAirTrack = sourceID.flatMap { tracks[$0] }
        let sink = sourceID.flatMap { sinks[$0] }
        lock.unlock()
        sink?.replayAssignedLanes()
    }

    /// Routes already-decoded signals into program lanes. Does not add or remove WebRTC renderers.
    public func setDisplayTracks(
        onAir: RTCVideoTrack?,
        incoming: RTCVideoTrack?,
        outgoing: RTCVideoTrack?
    ) {
        lock.lock()
        let changed = onAirTrack !== onAir || incomingTrack !== incoming || outgoingTrack !== outgoing
        onAirTrack = onAir
        incomingTrack = incoming
        outgoingTrack = outgoing
        if let onAir, let match = tracks.first(where: { $0.value === onAir })?.key {
            liveSelection = match
        }
        let activeSinks = Array(sinks.values)
        lock.unlock()
        guard changed else { return }
        for sink in activeSinks {
            sink.replayAssignedLanes()
        }
    }

    func lanes(for sourceID: CameraSourceID) -> [ProgramFrameBusSlot] {
        lock.lock()
        let track = tracks[sourceID]
        let onAir = onAirTrack
        let incoming = incomingTrack
        let outgoing = outgoingTrack
        lock.unlock()
        guard let track else { return [] }
        var lanes: [ProgramFrameBusSlot] = []
        if onAir === track { lanes.append(.programOnAir) }
        if incoming === track { lanes.append(.programIncoming) }
        if outgoing === track { lanes.append(.programOutgoing) }
        return lanes
    }

    func isLiveSelection(_ sourceID: CameraSourceID) -> Bool {
        lanes(for: sourceID).contains(.programOnAir)
    }

    func store(sink: SignalSink, for sourceID: CameraSourceID) {
        lock.lock()
        sinks[sourceID] = sink
        lock.unlock()
    }

    private func attach(sourceID: CameraSourceID, track: RTCVideoTrack) {
        detach(sourceID)
        let sink = SignalSink(sourceID: sourceID, cache: self)
        track.add(sink)
        store(sink: sink, for: sourceID)
        lock.lock()
        tracks[sourceID] = track
        lock.unlock()
    }

    private func detach(_ sourceID: CameraSourceID) {
        lock.lock()
        let sink = sinks.removeValue(forKey: sourceID)
        let track = tracks[sourceID]
        lock.unlock()
        if let sink, let track {
            track.remove(sink)
        }
    }
}

final class SignalSink: NSObject, RTCVideoRenderer, @unchecked Sendable {
    let sourceID: CameraSourceID
    private weak var cache: DirectorDecodedSignalCache?
    private let lock = NSLock()
    private var latest: CVPixelBuffer?

    init(sourceID: CameraSourceID, cache: DirectorDecodedSignalCache) {
        self.sourceID = sourceID
        self.cache = cache
    }

    func setSize(_ size: CGSize) {}

    func renderFrame(_ frame: RTCVideoFrame?) {
        guard let frame,
              let pixelBuffer = WebRTCVideoFramePixelBuffer.extract(from: frame) else {
            return
        }
        lock.lock()
        latest = pixelBuffer
        lock.unlock()
        publish(pixelBuffer)
    }

    func replayAssignedLanes() {
        lock.lock()
        let frame = latest
        lock.unlock()
        guard let frame else { return }
        publish(frame)
    }

    private func publish(_ pixelBuffer: CVPixelBuffer) {
        guard let cache else { return }
        let lanes = cache.lanes(for: sourceID)
        guard !lanes.isEmpty else { return }
        for lane in lanes {
            ProgramFrameDisplayBus.shared.publish(pixelBuffer: pixelBuffer, lane: lane, enforceQualityGate: false)
        }
    }
}
