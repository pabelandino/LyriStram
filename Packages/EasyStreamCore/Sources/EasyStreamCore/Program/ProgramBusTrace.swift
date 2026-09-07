import Foundation

/// Throttled tracing for the PROG video pipeline. Filter Console with:
/// `subsystem:com.easystream category:ProgramBus`
public enum ProgramBusTrace: Sendable {
    private static let throttleLock = NSLock()
    nonisolated(unsafe) private static var lastEventAt: [String: CFAbsoluteTime] = [:]
    nonisolated(unsafe) private static var lastLaneSize: [String: (width: Int, height: Int)] = [:]

    public static func event(_ message: String) {
        EasyStreamLog.programBus.info("\(message, privacy: .public)")
    }

    /// Logs at most once per interval for the same key (high-frequency paths).
    public static func eventThrottled(
        _ key: String,
        intervalMs: Int = 400,
        _ message: String
    ) {
        throttleLock.lock()
        let now = CFAbsoluteTimeGetCurrent()
        let interval = Double(intervalMs) / 1_000.0
        if let last = lastEventAt[key], now - last < interval {
            throttleLock.unlock()
            return
        }
        lastEventAt[key] = now
        throttleLock.unlock()
        event(message)
    }

    /// Logs lane publishes when dimensions change or on first frame (avoids per-frame spam).
    public static func lanePublish(
        lane: ProgramFrameBusSlot,
        width: Int,
        height: Int,
        sequence: UInt64
    ) {
        logSizeChange(key: "lane:\(lane.rawValue)", width: width, height: height) { message in
            event("bus publish \(message) seq=\(sequence)")
        }
    }

    public static func compositorPresent(width: Int, height: Int, transitioning: Bool) {
        logSizeChange(key: "compositor", width: width, height: height) { message in
            event("compositor present \(message) transitioning=\(transitioning)")
        }
    }

    private static func logSizeChange(
        key: String,
        width: Int,
        height: Int,
        emit: (String) -> Void
    ) {
        throttleLock.lock()
        let previous = lastLaneSize[key]
        let sizeChanged = previous.map { $0.width != width || $0.height != height } ?? true
        if sizeChanged {
            lastLaneSize[key] = (width, height)
        }
        throttleLock.unlock()

        guard sizeChanged else { return }
        emit("\(width)x\(height)")
    }

    public static func shortTrackId(_ trackId: String?) -> String {
        guard let trackId, !trackId.isEmpty else { return "-" }
        return String(trackId.prefix(8))
    }

    public static func shortSourceID(_ id: UUID?) -> String {
        guard let id else { return "-" }
        return String(id.uuidString.prefix(8))
    }
}
