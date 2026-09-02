import Foundation

/// Tracks live WebRTC Metal renderer attachments for director performance diagnostics.
public enum VideoRendererSinkCategory: String, Sendable {
    case tile
    case program
    case previewMonitor
    case programCrossfade
    case externalOutput
    case encoder
    case other
}

public struct VideoRendererSinkSnapshot: Sendable, Equatable {
    public let totalActiveSinks: Int
    public let countsByCategory: [VideoRendererSinkCategory: Int]

    public init(totalActiveSinks: Int, countsByCategory: [VideoRendererSinkCategory: Int]) {
        self.totalActiveSinks = totalActiveSinks
        self.countsByCategory = countsByCategory
    }
}

public enum VideoRendererSinkRegistry {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var counts: [VideoRendererSinkCategory: Int] = [:]

    public static func register(_ category: VideoRendererSinkCategory) {
        lock.lock()
        counts[category, default: 0] += 1
        lock.unlock()
    }

    public static func unregister(_ category: VideoRendererSinkCategory) {
        lock.lock()
        let next = (counts[category] ?? 0) - 1
        if next <= 0 {
            counts.removeValue(forKey: category)
        } else {
            counts[category] = next
        }
        lock.unlock()
    }

    public static func snapshot() -> VideoRendererSinkSnapshot {
        lock.lock()
        let copy = counts
        lock.unlock()
        return VideoRendererSinkSnapshot(
            totalActiveSinks: copy.values.reduce(0, +),
            countsByCategory: copy
        )
    }
}
