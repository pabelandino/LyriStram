import CoreGraphics
import CoreVideo
import Foundation

/// Full-frame program picture that replaces the camera. Widgets stay as sprites above it.
final class BroadcastProgramPlateBus: @unchecked Sendable {
    static let shared = BroadcastProgramPlateBus()

    struct Frame: @unchecked Sendable {
        var rgba: Data
        var width: Int
        var height: Int
    }

    /// Encoded video frame. The compositor samples it directly; no CPU bitmap copy.
    struct VideoSample: @unchecked Sendable {
        var pixelBuffer: CVPixelBuffer
        var displayTransform: CGAffineTransform
    }

    struct Status: Sendable {
        var generation: UInt64
        var animating: Bool
        var hasFrame: Bool
    }

    private let lock = NSLock()
    private var frame: Frame?
    private var videoSample: VideoSample?
    private var generation: UInt64 = 0
    private var animating = false
    private var listeners: [@Sendable () -> Void] = []

    private init() {}

    func addListener(_ listener: @escaping @Sendable () -> Void) {
        lock.lock()
        listeners.append(listener)
        lock.unlock()
    }

    func setFrame(_ frame: Frame?, animating: Bool) {
        lock.lock()
        let wasAnimating = self.animating
        let hadFrame = self.frame != nil || self.videoSample != nil
        self.videoSample = nil
        self.frame = frame
        self.animating = animating && frame != nil
        generation &+= 1
        let callbacks = listeners
        let shouldWake = frame == nil || !wasAnimating || !hadFrame
        lock.unlock()
        guard shouldWake else { return }
        DispatchQueue.main.async {
            callbacks.forEach { $0() }
        }
    }

    /// Publishes one video buffer. Listeners wake only when the plate appears, disappears, or starts.
    func setVideoSample(_ sample: VideoSample?, animating: Bool) {
        lock.lock()
        let wasAnimating = self.animating
        let hadFrame = self.frame != nil || self.videoSample != nil
        self.frame = nil
        self.videoSample = sample
        self.animating = animating && sample != nil
        generation &+= 1
        let callbacks = listeners
        let shouldWake = sample == nil || !wasAnimating || !hadFrame
        lock.unlock()
        guard shouldWake else { return }
        DispatchQueue.main.async {
            callbacks.forEach { $0() }
        }
    }

    func setVideoAnimating(_ animating: Bool) {
        lock.lock()
        let wasAnimating = self.animating
        guard videoSample != nil else {
            lock.unlock()
            return
        }
        self.animating = animating
        generation &+= 1
        let callbacks = listeners
        let shouldWake = animating && !wasAnimating
        lock.unlock()
        guard shouldWake else { return }
        DispatchQueue.main.async {
            callbacks.forEach { $0() }
        }
    }

    func currentVideoSample() -> VideoSample? {
        lock.lock()
        defer { lock.unlock() }
        return videoSample
    }

    func status() -> Status {
        lock.lock()
        defer { lock.unlock() }
        return Status(generation: generation, animating: animating, hasFrame: frame != nil || videoSample != nil)
    }

    /// Copies the bitmap only when the compositor has not uploaded this generation.
    func frame(ifGenerationDiffersFrom uploaded: UInt64) -> (generation: UInt64, frame: Frame)? {
        lock.lock()
        defer { lock.unlock() }
        guard generation != uploaded, let frame else { return nil }
        return (generation, frame)
    }
}
