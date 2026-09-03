import Foundation
import EasyStreamCore
import WebRTC

/// Infrastructure adapter — thread-safe frame telemetry for the program compositor bus.
public final class ProgramFrameBus: ProgramFrameTelemetryPort, @unchecked Sendable {
    public static let shared = ProgramFrameBus()

    @available(*, deprecated, message: "Use ProgramFrameTrackTelemetry from EasyStreamCore")
    public struct TrackSnapshot: Sendable, Equatable {
        public let trackID: String
        public let frameCount: UInt64
        public let contentSize: CGSize

        public init(trackID: String, frameCount: UInt64, contentSize: CGSize) {
            self.trackID = trackID
            self.frameCount = frameCount
            self.contentSize = contentSize
        }
    }

    private struct MutableTrackState {
        var frameCount: UInt64 = 0
        var contentSize: CGSize = .zero
    }

    private let lock = NSLock()
    nonisolated(unsafe) private var tracks: [ProgramFrameBusSlot: MutableTrackState] = [:]

    private init() {}

    public func recordFrame(from frame: RTCVideoFrame, track: RTCVideoTrack?) {
        if let trackID = track?.trackId, let slot = ProgramFrameBusSlot(busSlotName: trackID) {
            recordFrame(busSlot: slot, width: Int(frame.width), height: Int(frame.height))
        } else {
            recordFrame(
                busSlot: .programOnAir,
                width: Int(frame.width),
                height: Int(frame.height)
            )
        }
    }

    public func recordFrame(from frame: RTCVideoFrame, busSlot: String) {
        if let slot = ProgramFrameBusSlot(busSlotName: busSlot) {
            recordFrame(busSlot: slot, width: Int(frame.width), height: Int(frame.height))
        }
    }

    public func recordFrame(busSlot: ProgramFrameBusSlot, width: Int, height: Int) {
        lock.lock()
        var state = tracks[busSlot, default: MutableTrackState()]
        state.frameCount += 1
        state.contentSize = CGSize(width: width, height: height)
        tracks[busSlot] = state
        lock.unlock()
    }

    public func snapshot() -> [ProgramFrameTrackTelemetry] {
        lock.lock()
        let copy = tracks
        lock.unlock()
        return ProgramFrameBusSlot.allCases.compactMap { slot in
            guard let state = copy[slot] else { return nil }
            return ProgramFrameTrackTelemetry(
                busSlot: slot,
                frameCount: state.frameCount,
                contentSize: state.contentSize
            )
        }
    }

    public func legacySnapshot() -> [TrackSnapshot] {
        snapshot().map {
            TrackSnapshot(
                trackID: $0.busSlot.rawValue,
                frameCount: $0.frameCount,
                contentSize: $0.contentSize
            )
        }
    }

    public func reset() {
        lock.lock()
        tracks.removeAll()
        lock.unlock()
    }
}

public extension ProgramFrameBusSlot {
    init?(busSlotName: String) {
        self.init(rawValue: busSlotName)
    }
}
