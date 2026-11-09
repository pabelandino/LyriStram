import CoreVideo
import WebRTC

public enum WebRTCVideoFramePixelBuffer {
    /// Returns a buffer the director owns. The camera decoder's buffer is never kept:
    /// holding it stalls every preview of that camera once the pool runs out.
    public static func extract(from frame: RTCVideoFrame) -> CVPixelBuffer? {
        if let cvBuffer = frame.buffer as? RTCCVPixelBuffer {
            return PixelBufferCopy.shared.ownedCopy(of: cvBuffer.pixelBuffer)
        }
        if let i420 = frame.buffer as? RTCI420Buffer {
            return I420ToNV12Converter.shared.pixelBuffer(from: i420)
        }
        return nil
    }
}

/// Copies a decoded camera buffer into a director-owned pool so the decoder can reuse its own.
final class PixelBufferCopy: @unchecked Sendable {
    static let shared = PixelBufferCopy()

    private struct PoolKey: Hashable {
        let width: Int
        let height: Int
        let format: OSType
    }

    private let lock = NSLock()
    private var pools: [PoolKey: CVPixelBufferPool] = [:]

    func ownedCopy(of source: CVPixelBuffer) -> CVPixelBuffer? {
        let width = CVPixelBufferGetWidth(source)
        let height = CVPixelBufferGetHeight(source)
        let format = CVPixelBufferGetPixelFormatType(source)
        guard width > 0, height > 0 else { return nil }

        let key = PoolKey(width: width, height: height, format: format)
        lock.lock()
        let pool: CVPixelBufferPool
        if let existing = pools[key] {
            pool = existing
        } else if let created = Self.makePool(width: width, height: height, format: format) {
            pools[key] = created
            pool = created
        } else {
            lock.unlock()
            return nil
        }
        var destination: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &destination)
        lock.unlock()
        guard status == kCVReturnSuccess, let destination else { return nil }
        guard Self.copyPlanes(from: source, to: destination) else { return nil }
        return destination
    }

    private static func makePool(width: Int, height: Int, format: OSType) -> CVPixelBufferPool? {
        let bufferAttrs: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: format,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferMetalCompatibilityKey as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:],
        ]
        let poolAttrs: [String: Any] = [
            kCVPixelBufferPoolMinimumBufferCountKey as String: 6,
        ]
        var pool: CVPixelBufferPool?
        CVPixelBufferPoolCreate(
            kCFAllocatorDefault,
            poolAttrs as CFDictionary,
            bufferAttrs as CFDictionary,
            &pool
        )
        return pool
    }

    private static func copyPlanes(from source: CVPixelBuffer, to destination: CVPixelBuffer) -> Bool {
        let readOnly = CVPixelBufferLockFlags.readOnly
        guard CVPixelBufferLockBaseAddress(source, readOnly) == kCVReturnSuccess else { return false }
        defer { CVPixelBufferUnlockBaseAddress(source, readOnly) }
        guard CVPixelBufferLockBaseAddress(destination, []) == kCVReturnSuccess else { return false }
        defer { CVPixelBufferUnlockBaseAddress(destination, []) }

        let planeCount = CVPixelBufferGetPlaneCount(source)
        if planeCount == 0 {
            return copyBase(from: source, to: destination)
        }
        guard CVPixelBufferGetPlaneCount(destination) == planeCount else { return false }
        for plane in 0..<planeCount {
            guard copyPlane(plane, from: source, to: destination) else { return false }
        }
        return true
    }

    private static func copyBase(from source: CVPixelBuffer, to destination: CVPixelBuffer) -> Bool {
        guard let src = CVPixelBufferGetBaseAddress(source),
              let dst = CVPixelBufferGetBaseAddress(destination) else { return false }
        let height = CVPixelBufferGetHeight(source)
        let srcStride = CVPixelBufferGetBytesPerRow(source)
        let dstStride = CVPixelBufferGetBytesPerRow(destination)
        let rowBytes = min(srcStride, dstStride)
        guard height > 0, rowBytes > 0 else { return false }
        for row in 0..<height {
            memcpy(dst.advanced(by: row * dstStride), src.advanced(by: row * srcStride), rowBytes)
        }
        return true
    }

    private static func copyPlane(_ plane: Int, from source: CVPixelBuffer, to destination: CVPixelBuffer) -> Bool {
        guard let src = CVPixelBufferGetBaseAddressOfPlane(source, plane),
              let dst = CVPixelBufferGetBaseAddressOfPlane(destination, plane) else { return false }
        let height = CVPixelBufferGetHeightOfPlane(source, plane)
        let srcStride = CVPixelBufferGetBytesPerRowOfPlane(source, plane)
        let dstStride = CVPixelBufferGetBytesPerRowOfPlane(destination, plane)
        let rowBytes = min(srcStride, dstStride)
        guard height > 0, rowBytes > 0 else { return false }
        for row in 0..<height {
            memcpy(dst.advanced(by: row * dstStride), src.advanced(by: row * srcStride), rowBytes)
        }
        return true
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
        if pool == nil || poolWidth != width || poolHeight != height {
            pool = nil
            let bufferAttrs: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height,
                kCVPixelBufferMetalCompatibilityKey as String: true,
                kCVPixelBufferIOSurfacePropertiesKey as String: [:],
            ]
            let poolAttrs: [String: Any] = [
                kCVPixelBufferPoolMinimumBufferCountKey as String: 8,
            ]
            CVPixelBufferPoolCreate(
                kCFAllocatorDefault,
                poolAttrs as CFDictionary,
                bufferAttrs as CFDictionary,
                &pool
            )
            poolWidth = width
            poolHeight = height
        }

        guard let pool else {
            lock.unlock()
            return nil
        }

        var pixelBuffer: CVPixelBuffer?
        let created = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pixelBuffer)
        lock.unlock()
        guard created == kCVReturnSuccess, let pixelBuffer else {
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
