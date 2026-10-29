import Foundation

/// Throttled tracing for idle tile thumbnails (Phase 2). Filter Console with:
/// `subsystem:com.easystream category:ProgramBus` and search `tile-thumb`.
public enum TileThumbnailTrace: Sendable {
    public static func event(_ message: String) {
        ProgramBusTrace.event("tile-thumb \(message)")
    }

    public static func eventThrottled(
        _ key: String,
        intervalMs: Int = 800,
        _ message: String
    ) {
        ProgramBusTrace.eventThrottled("tile-thumb:\(key)", intervalMs: intervalMs, "tile-thumb \(message)")
    }
}
