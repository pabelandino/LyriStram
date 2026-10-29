import CoreImage
import CoreVideo
import EasyStreamCore
import Foundation
import WebRTC

/// Throttled WebRTC sink — publishes ~1 fps downscaled frames for idle director tiles.
public final class BroadcastTileThumbnailSink: NSObject, RTCVideoRenderer, @unchecked Sendable {
    public let sourceID: CameraSourceID

    private let processingQueue = DispatchQueue(
        label: "com.easystream.tile-thumbnail-sink",
        qos: .utility
    )
    private let ciContext = CIContext(options: [.cacheIntermediates: false])
    private let publishLock = NSLock()
    private var lastPublishUptime: TimeInterval = 0
    private var sequence: UInt64 = 0
    private let minPublishInterval: TimeInterval = 1.0
    private let maxThumbnailWidth = 128

    public init(sourceID: CameraSourceID) {
        self.sourceID = sourceID
    }

    public func setSize(_ size: CGSize) {}

    public func renderFrame(_ frame: RTCVideoFrame?) {
        guard let frame else { return }
        publishLock.lock()
        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastPublishUptime >= minPublishInterval else {
            publishLock.unlock()
            return
        }
        lastPublishUptime = now
        publishLock.unlock()

        processingQueue.async { [weak self] in
            self?.process(frame)
        }
    }

    private func process(_ frame: RTCVideoFrame) {
        publishLock.lock()
        sequence &+= 1
        let seq = sequence
        publishLock.unlock()

        guard let pixelBuffer = WebRTCVideoFramePixelBuffer.extract(from: frame),
              let thumbnail = Self.downscale(pixelBuffer, maxWidth: maxThumbnailWidth, context: ciContext) else {
            return
        }

        DirectorSourceThumbnailBus.shared.publish(
            sourceID: sourceID,
            pixelBuffer: thumbnail,
            sequence: seq
        )

        let width = CVPixelBufferGetWidth(thumbnail)
        let height = CVPixelBufferGetHeight(thumbnail)
        TileThumbnailTrace.eventThrottled(
            "publish-\(sourceID.rawValue.uuidString.prefix(8))",
            intervalMs: 2_000,
            "publish source=\(ProgramBusTrace.shortSourceID(sourceID.rawValue)) \(width)x\(height) seq=\(seq)"
        )
    }

    private static func downscale(
        _ source: CVPixelBuffer,
        maxWidth: Int,
        context: CIContext
    ) -> CVPixelBuffer? {
        let width = CVPixelBufferGetWidth(source)
        let height = CVPixelBufferGetHeight(source)
        guard width > 0, height > 0 else { return nil }

        let image = CIImage(cvPixelBuffer: source)
        let scale = min(1, CGFloat(maxWidth) / CGFloat(width))
        let scaled = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let targetWidth = Int((CGFloat(width) * scale).rounded())
        let targetHeight = Int((CGFloat(height) * scale).rounded())

        var destination: CVPixelBuffer?
        let attrs: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: targetWidth,
            kCVPixelBufferHeightKey as String: targetHeight,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:],
        ]
        guard CVPixelBufferCreate(
            kCFAllocatorDefault,
            targetWidth,
            targetHeight,
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &destination
        ) == kCVReturnSuccess,
            let destination else {
            return nil
        }

        context.render(scaled, to: destination)
        return destination
    }
}
