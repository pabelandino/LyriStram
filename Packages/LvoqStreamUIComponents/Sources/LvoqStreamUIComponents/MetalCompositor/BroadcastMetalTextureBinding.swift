import CoreVideo
import Metal

/// CVMetalTexture refs retained until the GPU command buffer completes (WWDC20 lifecycle).
final class BroadcastMetalTextureBinding {
    private var retainedCVTextures: [CVMetalTexture] = []
    private var retainedPixelBuffers: [CVPixelBuffer] = []

    private(set) var outgoingPixelBuffer: CVPixelBuffer?
    private(set) var outgoingIsNV12 = false
    private(set) var incomingPixelBuffer: CVPixelBuffer?
    private(set) var incomingIsNV12 = false

    var outgoingBGRA: MTLTexture?
    var outgoingY: MTLTexture?
    var outgoingCbCr: MTLTexture?
    var incomingBGRA: MTLTexture?
    var incomingY: MTLTexture?
    var incomingCbCr: MTLTexture?

    var hasOutgoingVideo: Bool {
        outgoingBGRA != nil || (outgoingY != nil && outgoingCbCr != nil)
    }

    var hasIncomingVideo: Bool {
        incomingBGRA != nil || (incomingY != nil && incomingCbCr != nil)
    }

    func bindOutgoing(from pixelBuffer: CVPixelBuffer?, isNV12: Bool, cache: CVMetalTextureCache?) {
        outgoingPixelBuffer = pixelBuffer
        outgoingIsNV12 = isNV12
        guard let pixelBuffer, let cache else { return }
        retainPixelBuffer(pixelBuffer)
        if isNV12 {
            let planes = makeNV12(from: pixelBuffer, cache: cache)
            outgoingY = planes.y
            outgoingCbCr = planes.cbcr
        } else {
            outgoingBGRA = makeBGRA(from: pixelBuffer, cache: cache)
        }
    }

    func bindIncoming(from pixelBuffer: CVPixelBuffer?, isNV12: Bool, cache: CVMetalTextureCache?) {
        incomingPixelBuffer = pixelBuffer
        incomingIsNV12 = isNV12
        guard let pixelBuffer, let cache else { return }
        retainPixelBuffer(pixelBuffer)
        if isNV12 {
            let planes = makeNV12(from: pixelBuffer, cache: cache)
            incomingY = planes.y
            incomingCbCr = planes.cbcr
        } else {
            incomingBGRA = makeBGRA(from: pixelBuffer, cache: cache)
        }
    }

    private func makeBGRA(from pixelBuffer: CVPixelBuffer, cache: CVMetalTextureCache) -> MTLTexture? {
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
        retainedCVTextures.append(cvTexture)
        return CVMetalTextureGetTexture(cvTexture)
    }

    private func makeNV12(
        from pixelBuffer: CVPixelBuffer,
        cache: CVMetalTextureCache
    ) -> (y: MTLTexture?, cbcr: MTLTexture?) {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        var yCV: CVMetalTexture?
        var cbcrCV: CVMetalTexture?

        let yStatus = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            cache,
            pixelBuffer,
            nil,
            .r8Unorm,
            width,
            height,
            0,
            &yCV
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
            &cbcrCV
        )

        guard yStatus == kCVReturnSuccess, cbcrStatus == kCVReturnSuccess,
              let yCV, let cbcrCV else {
            return (nil, nil)
        }

        retainedCVTextures.append(yCV)
        retainedCVTextures.append(cbcrCV)
        return (CVMetalTextureGetTexture(yCV), CVMetalTextureGetTexture(cbcrCV))
    }

    private func retainPixelBuffer(_ buffer: CVPixelBuffer) {
        retainedPixelBuffers.append(buffer)
    }

    /// Releases Swift ARC holds after GPU finishes (call from command buffer handler).
    func releaseAfterGPU() {
        outgoingPixelBuffer = nil
        incomingPixelBuffer = nil
        outgoingBGRA = nil
        outgoingY = nil
        outgoingCbCr = nil
        incomingBGRA = nil
        incomingY = nil
        incomingCbCr = nil
        retainedPixelBuffers.removeAll()
        retainedCVTextures.removeAll()
    }
}
