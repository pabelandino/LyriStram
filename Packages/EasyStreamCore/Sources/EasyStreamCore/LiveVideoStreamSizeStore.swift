import CoreGraphics
import Foundation
import Observation

/// Observed decode dimensions reported by WebRTC renderers (not saved presets).
@MainActor
@Observable
public final class LiveVideoStreamSizeStore {
    public static let shared = LiveVideoStreamSizeStore()

    private(set) var sizesByTrackId: [String: CGSize] = [:]

    private init() {}

    public func update(trackId: String, size: CGSize) {
        guard trackId.isEmpty == false, size.width > 1, size.height > 1 else { return }
        if sizesByTrackId[trackId] != size {
            sizesByTrackId[trackId] = size
        }
    }

    public func size(forTrackId trackId: String?) -> CGSize? {
        guard let trackId else { return nil }
        return sizesByTrackId[trackId]
    }

    public func label(forTrackId trackId: String?) -> String? {
        guard let size = size(forTrackId: trackId), size.width > 1, size.height > 1 else { return nil }
        return "\(Int(size.width))×\(Int(size.height))"
    }
}
