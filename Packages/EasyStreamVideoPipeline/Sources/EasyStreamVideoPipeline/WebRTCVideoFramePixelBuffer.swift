import CoreVideo
import WebRTC

enum WebRTCVideoFramePixelBuffer {
    static func extract(from frame: RTCVideoFrame) -> CVPixelBuffer? {
        if let cvBuffer = frame.buffer as? RTCCVPixelBuffer {
            return cvBuffer.pixelBuffer
        }
        if let i420 = frame.buffer as? RTCI420Buffer {
            return I420ToNV12Converter.shared.pixelBuffer(from: i420)
        }
        return nil
    }
}

/// Converts WebRTC I420 frames to NV12 CVPixelBuffers for encode/display pipelines.
final class I420ToNV12Converter: @unchecked Sendable {
    static let shared = I420ToNV12Converter()

    private let lock = NSLock()
    private var pool: CVPixelBufferPool?
    private var poolWidth = 0
    private var poolHeight = 0

    func pixelBuffer(from i420: RTCI420Buffer) -> CVPixelBuffer? {
        let width = Int(i420.width)
        let height = Int(i420.height)
        guard width > 0, height > 0 else { return nil }

        lock.lock()
        defer { lock.unlock() }

        if pool == nil || poolWidth != width || poolHeight != height {
            pool = nil
            let attrs: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height,
                kCVPixelBufferMetalCompatibilityKey as String: true,
                kCVPixelBufferIOSurfacePropertiesKey as String: [:],
            ]
            CVPixelBufferPoolCreate(kCFAllocatorDefault, nil, attrs as CFDictionary, &pool)
            poolWidth = width
            poolHeight = height
        }

        guard let pool else { return nil }

        var pixelBuffer: CVPixelBuffer?
        guard CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pixelBuffer) == kCVReturnSuccess,
              let pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

        let yPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)!
        let yStride = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
        let yRows = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        for row in 0..<yRows {
            memcpy(
                yPlane.advanced(by: row * yStride),
                i420.dataY.advanced(by: row * Int(i420.strideY)),
                width
            )
        }

        let cbcrPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1)!
        let cbcrStride = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1)
        let cbcrRows = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1)
        for row in 0..<cbcrRows {
            let uRow = i420.dataU.advanced(by: row * Int(i420.strideU))
            let vRow = i420.dataV.advanced(by: row * Int(i420.strideV))
            let dest = cbcrPlane.advanced(by: row * cbcrStride).assumingMemoryBound(to: UInt8.self)
            for col in 0..<(width / 2) {
                dest[col * 2] = uRow[col]
                dest[col * 2 + 1] = vRow[col]
            }
        }

        return pixelBuffer
    }
}
