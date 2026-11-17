import CoreGraphics
import CoreVideo
import Metal
import MetalKit
import WebRTC

enum BroadcastMetalTextureUploader {
    static func makeBGRATexture(
        from pixelBuffer: CVPixelBuffer?,
        cache: CVMetalTextureCache?
    ) -> MTLTexture? {
        guard let pixelBuffer, let cache else { return nil }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var cvTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            cache,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            width,
            height,
            0,
            &cvTexture
        )
        guard status == kCVReturnSuccess, let cvTexture else { return nil }
        return CVMetalTextureGetTexture(cvTexture)
    }

    static func makeNV12Textures(
        from pixelBuffer: CVPixelBuffer?,
        cache: CVMetalTextureCache?
    ) -> (y: MTLTexture?, cbcr: MTLTexture?) {
        guard let pixelBuffer, let cache else { return (nil, nil) }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        var yTexture: CVMetalTexture?
        var cbcrTexture: CVMetalTexture?

        let yStatus = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            cache,
            pixelBuffer,
            nil,
            .r8Unorm,
            width,
            height,
            0,
            &yTexture
        )

        let cbcrStatus = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            cache,
            pixelBuffer,
            nil,
            .rg8Unorm,
            width / 2,
            height / 2,
            1,
            &cbcrTexture
        )

        guard yStatus == kCVReturnSuccess, cbcrStatus == kCVReturnSuccess else {
            return (nil, nil)
        }

        return (
            y: yTexture.flatMap { CVMetalTextureGetTexture($0) },
            cbcr: cbcrTexture.flatMap { CVMetalTextureGetTexture($0) }
        )
    }

    static func makeTexture(from cgImage: CGImage, device: MTLDevice) -> MTLTexture? {
        let loader = MTKTextureLoader(device: device)
        return try? loader.newTexture(
            cgImage: cgImage,
            options: [.SRGB: false, .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue)]
        )
    }
}

/// Reuses NV12 buffers when WebRTC delivers I420 (common for software decode on macOS).
private final class BroadcastMetalI420ConversionCache: @unchecked Sendable {
    static let shared = BroadcastMetalI420ConversionCache()

    private let lock = NSLock()
    private var pool: CVPixelBufferPool?
    private var poolWidth = 0
    private var poolHeight = 0

    func nv12PixelBuffer(from i420: RTCI420Buffer) -> CVPixelBuffer? {
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

enum BroadcastMetalVideoFrame {
    struct LayerFrame {
        var pixelBuffer: CVPixelBuffer?
        var contentSize: SIMD2<Float> = .zero
        var isNV12 = false
    }

    static func layerFrame(from rtcFrame: RTCVideoFrame) -> LayerFrame {
        if let cvBuffer = rtcFrame.buffer as? RTCCVPixelBuffer {
            let pixelBuffer = cvBuffer.pixelBuffer
            let width = Float(CVPixelBufferGetWidth(pixelBuffer))
            let height = Float(CVPixelBufferGetHeight(pixelBuffer))
            let format = CVPixelBufferGetPixelFormatType(pixelBuffer)
            let isNV12 = format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
                || format == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
            return LayerFrame(
                pixelBuffer: pixelBuffer,
                contentSize: SIMD2(width, height),
                isNV12: isNV12
            )
        }

        if let i420 = rtcFrame.buffer as? RTCI420Buffer,
           let pixelBuffer = BroadcastMetalI420ConversionCache.shared.nv12PixelBuffer(from: i420) {
            let width = Float(i420.width)
            let height = Float(i420.height)
            return LayerFrame(
                pixelBuffer: pixelBuffer,
                contentSize: SIMD2(width, height),
                isNV12: true
            )
        }

        return LayerFrame()
    }
}
