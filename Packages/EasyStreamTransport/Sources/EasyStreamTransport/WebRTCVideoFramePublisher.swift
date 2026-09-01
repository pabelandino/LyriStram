import CoreVideo
import Foundation
import WebRTC
import EasyStreamCore

/// Publishes capture frames directly to WebRTC without actor hops (target fps path).
public final class WebRTCVideoFramePublisher: @unchecked Sendable {
    private let lock = NSLock()
    private var videoSource: RTCVideoSource?
    private let capturer = RTCVideoCapturer()
    private var lastPublishedTimestampNs: Int64 = 0
    private let minFrameIntervalNs: Int64

    public init(targetFrameRate: Int32 = CameraTransportDefaults.frameRate) {
        minFrameIntervalNs = 1_000_000_000 / Int64(max(1, targetFrameRate))
    }

    public func attach(to source: RTCVideoSource?) {
        lock.lock()
        videoSource = source
        lastPublishedTimestampNs = 0
        lock.unlock()
    }

    public func publish(
        pixelBuffer: CVPixelBuffer,
        timestampNs: Int64,
        rotation: RTCVideoRotation = ._0
    ) {
        lock.lock()
        let source = videoSource
        guard source != nil else {
            lock.unlock()
            return
        }

        if lastPublishedTimestampNs > 0,
           timestampNs &- lastPublishedTimestampNs < minFrameIntervalNs {
            lock.unlock()
            return
        }
        lastPublishedTimestampNs = timestampNs
        lock.unlock()

        let rtcBuffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer)
        let frame = RTCVideoFrame(buffer: rtcBuffer, rotation: rotation, timeStampNs: timestampNs)
        source?.capturer(capturer, didCapture: frame)
    }
}
