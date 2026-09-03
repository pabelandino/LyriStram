import Foundation

/// Domain port — infrastructure records decoded frame activity without exposing WebRTC types.
public protocol ProgramFrameTelemetryPort: Sendable {
    func recordFrame(busSlot: ProgramFrameBusSlot, width: Int, height: Int)
    func snapshot() -> [ProgramFrameTrackTelemetry]
    func reset()
}

public enum ProgramFrameBusSlot: String, Sendable, CaseIterable {
    case programOnAir = "program.onair"
    case programOutgoing = "program.outgoing"
    case programIncoming = "program.incoming"
}

public struct ProgramFrameTrackTelemetry: Sendable, Equatable {
    public let busSlot: ProgramFrameBusSlot
    public let frameCount: UInt64
    public let contentSize: CGSize

    public init(busSlot: ProgramFrameBusSlot, frameCount: UInt64, contentSize: CGSize) {
        self.busSlot = busSlot
        self.frameCount = frameCount
        self.contentSize = contentSize
    }
}

/// Dependency injection anchor for telemetry adapters (Metal sinks, encoders, thumbnails).
public enum ProgramFrameTelemetryRegistry {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var _live: any ProgramFrameTelemetryPort = ProgramFrameTelemetryNoOp()

    public static var live: any ProgramFrameTelemetryPort {
        lock.lock()
        defer { lock.unlock() }
        return _live
    }

    public static func install(_ port: any ProgramFrameTelemetryPort) {
        lock.lock()
        _live = port
        lock.unlock()
    }
}

private struct ProgramFrameTelemetryNoOp: ProgramFrameTelemetryPort {
    func recordFrame(busSlot: ProgramFrameBusSlot, width: Int, height: Int) {}
    func snapshot() -> [ProgramFrameTrackTelemetry] { [] }
    func reset() {}
}
