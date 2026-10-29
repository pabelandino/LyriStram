import CoreVideo
import EasyStreamCore
import Foundation

/// Latest downscaled tile frame per camera — JPEG lane (Phase 2b) or pixel buffer (legacy sink).
public final class DirectorSourceThumbnailBus: @unchecked Sendable {
    public static let shared = DirectorSourceThumbnailBus()

    public struct Snapshot: Sendable {
        public let pixelBuffer: CVPixelBuffer?
        public let jpegData: Data?
        public let sequence: UInt64
        public let contentSize: SIMD2<Int>
    }

    public var onThumbnailUpdated: (@Sendable (CameraSourceID) -> Void)?

    private let lock = NSLock()
    private var frames: [CameraSourceID: Snapshot] = [:]

    private init() {}

    public func publish(sourceID: CameraSourceID, pixelBuffer: CVPixelBuffer, sequence: UInt64) {
        lock.lock()
        frames[sourceID] = Snapshot(
            pixelBuffer: pixelBuffer,
            jpegData: nil,
            sequence: sequence,
            contentSize: SIMD2(
                CVPixelBufferGetWidth(pixelBuffer),
                CVPixelBufferGetHeight(pixelBuffer)
            )
        )
        lock.unlock()
        onThumbnailUpdated?(sourceID)
    }

    /// Phase 2b — idle tile JPEG from signaling (no WebRTC decode on director).
    public func publishJPEG(sourceID: CameraSourceID, jpeg: Data, sequence: UInt64) {
        lock.lock()
        frames[sourceID] = Snapshot(
            pixelBuffer: nil,
            jpegData: jpeg,
            sequence: sequence,
            contentSize: .zero
        )
        lock.unlock()
        onThumbnailUpdated?(sourceID)
    }

    public func snapshot(for sourceID: CameraSourceID) -> Snapshot? {
        lock.lock()
        defer { lock.unlock() }
        return frames[sourceID]
    }

    public func remove(sourceID: CameraSourceID) {
        lock.lock()
        frames.removeValue(forKey: sourceID)
        lock.unlock()
        onThumbnailUpdated?(sourceID)
    }

    public func removeAll() {
        lock.lock()
        frames.removeAll()
        lock.unlock()
    }
}
