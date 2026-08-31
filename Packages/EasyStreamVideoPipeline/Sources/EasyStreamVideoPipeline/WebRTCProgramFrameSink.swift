import Foundation
import CoreMedia
import WebRTC

/// Receives decoded WebRTC frames from the Program video track.
final class WebRTCProgramFrameSink: NSObject, RTCVideoRenderer {
    var onFrame: (@Sendable (CVPixelBuffer, CMTime) -> Void)?

    func setSize(_ size: CGSize) {}

    func renderFrame(_ frame: RTCVideoFrame?) {
        guard let frame else { return }

        let pixelBuffer: CVPixelBuffer?
        if let cvBuffer = frame.buffer as? RTCCVPixelBuffer {
            pixelBuffer = cvBuffer.pixelBuffer
        } else {
            pixelBuffer = nil
        }

        guard let pixelBuffer else { return }

        let presentationTime = CMTime(value: CMTimeValue(frame.timeStampNs), timescale: 1_000_000_000)
        onFrame?(pixelBuffer, presentationTime)
    }
}
