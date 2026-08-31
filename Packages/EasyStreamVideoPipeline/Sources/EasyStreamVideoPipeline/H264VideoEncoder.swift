import Foundation
import CoreMedia
import VideoToolbox
import EasyStreamCore

public enum VideoEncoderError: Error, Sendable {
    case sessionCreationFailed(OSStatus)
    case configurationFailed(OSStatus)
    case encodeFailed(OSStatus)
    case sampleExtractionFailed
}

/// Hardware H.264 encoder backed by VideoToolbox.
public actor H264VideoEncoder {
    private var session: VTCompressionSession?
    private var configuration = VideoEncoderConfiguration.broadcast1080p30
    private var continuation: AsyncStream<EncodedVideoSample>.Continuation?
    private var callbackBridge: EncoderCallbackBridge?
    private var stats = VideoEncoderStats()
    private var isPrepared = false

    public init() {}

    public func encodedSamples() -> AsyncStream<EncodedVideoSample> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.stop() }
            }
        }
    }

    public func currentStats() -> VideoEncoderStats {
        stats
    }

    public func start(configuration: VideoEncoderConfiguration = .broadcast1080p30) throws {
        self.configuration = configuration
        stats.configuredBitrate = configuration.averageBitrate
        stats.isRunning = true
        isPrepared = false
    }

    public func encode(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) throws {
        let width = Int32(CVPixelBufferGetWidth(pixelBuffer))
        let height = Int32(CVPixelBufferGetHeight(pixelBuffer))

        if session == nil || width != configuration.width || height != configuration.height {
            configuration.width = width
            configuration.height = height
            try recreateSession(width: width, height: height)
        }

        guard let session else {
            throw VideoEncoderError.sessionCreationFailed(-1)
        }

        var flags: VTEncodeInfoFlags = []
        let status = VTCompressionSessionEncodeFrame(
            session,
            imageBuffer: pixelBuffer,
            presentationTimeStamp: presentationTime,
            duration: CMTime(value: 1, timescale: configuration.frameRate),
            frameProperties: nil,
            sourceFrameRefcon: nil,
            infoFlagsOut: &flags
        )

        guard status == noErr else {
            throw VideoEncoderError.encodeFailed(status)
        }
    }

    public func stop() {
        if let session {
            VTCompressionSessionCompleteFrames(session, untilPresentationTimeStamp: .invalid)
            VTCompressionSessionInvalidate(session)
        }
        session = nil
        callbackBridge = nil
        isPrepared = false
        stats.isRunning = false
        continuation?.finish()
        continuation = nil
    }

    private func recreateSession(width: Int32, height: Int32) throws {
        if let session {
            VTCompressionSessionInvalidate(session)
            self.session = nil
        }

        let bridge = EncoderCallbackBridge { [weak self] sampleBuffer in
            Task { await self?.handleEncodedSample(sampleBuffer) }
        }
        callbackBridge = bridge

        var newSession: VTCompressionSession?
        let encoderSpecification: CFDictionary? = {
#if os(iOS)
            if #available(iOS 17.4, *) {
                return [kVTVideoEncoderSpecification_RequireHardwareAcceleratedVideoEncoder: true] as CFDictionary
            }
            return nil
#else
            return [kVTVideoEncoderSpecification_RequireHardwareAcceleratedVideoEncoder: true] as CFDictionary
#endif
        }()

        let status = VTCompressionSessionCreate(
            allocator: kCFAllocatorDefault,
            width: width,
            height: height,
            codecType: kCMVideoCodecType_H264,
            encoderSpecification: encoderSpecification,
            imageBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            ] as CFDictionary,
            compressedDataAllocator: nil,
            outputCallback: Self.compressionOutputCallback,
            refcon: Unmanaged.passUnretained(bridge).toOpaque(),
            compressionSessionOut: &newSession
        )

        guard status == noErr, let newSession else {
            throw VideoEncoderError.sessionCreationFailed(status)
        }

        try applySessionProperties(to: newSession)
        let prepareStatus = VTCompressionSessionPrepareToEncodeFrames(newSession)
        guard prepareStatus == noErr else {
            throw VideoEncoderError.configurationFailed(prepareStatus)
        }

        session = newSession
        isPrepared = true
        EasyStreamLog.encoder.info("H.264 encoder ready at \(width)x\(height)")
    }

    private func applySessionProperties(to session: VTCompressionSession) throws {
        let properties: [(CFString, Any)] = [
            (kVTCompressionPropertyKey_RealTime, true),
            (kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_High_AutoLevel),
            (kVTCompressionPropertyKey_AverageBitRate, configuration.averageBitrate),
            (kVTCompressionPropertyKey_ExpectedFrameRate, configuration.frameRate),
            (kVTCompressionPropertyKey_MaxKeyFrameInterval, configuration.maxKeyFrameInterval),
            (kVTCompressionPropertyKey_AllowFrameReordering, false),
        ]

        for (key, value) in properties {
            let status = VTSessionSetProperty(session, key: key, value: value as CFTypeRef)
            guard status == noErr else {
                throw VideoEncoderError.configurationFailed(status)
            }
        }
    }

    private func handleEncodedSample(_ sampleBuffer: CMSampleBuffer) {
        guard CMSampleBufferDataIsReady(sampleBuffer),
              let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            return
        }

        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        let blockStatus = CMBlockBufferGetDataPointer(
            blockBuffer,
            atOffset: 0,
            lengthAtOffsetOut: nil,
            totalLengthOut: &length,
            dataPointerOut: &dataPointer
        )
        guard blockStatus == kCMBlockBufferNoErr, let dataPointer, length > 0 else {
            return
        }

        let data = Data(bytes: dataPointer, count: length)
        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let decodeTime = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
        let isKeyframe = !sampleBufferContainsNotSync(sampleBuffer)
        let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)

        stats.framesEncoded += 1
        stats.bytesEncoded += length
        if isKeyframe {
            stats.keyframesEncoded += 1
        }

        let sample = EncodedVideoSample(
            data: data,
            presentationTime: presentationTime,
            decodeTime: decodeTime.isValid ? decodeTime : nil,
            isKeyframe: isKeyframe,
            formatDescription: formatDescription
        )
        continuation?.yield(sample)
    }

    private func sampleBufferContainsNotSync(_ sampleBuffer: CMSampleBuffer) -> Bool {
        guard let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [[CFString: Any]],
              let first = attachments.first else {
            return false
        }
        return (first[kCMSampleAttachmentKey_NotSync] as? Bool) ?? false
    }

    private static let compressionOutputCallback: VTCompressionOutputCallback = { refcon, _, status, _, sampleBuffer in
        guard status == noErr, let refcon, let sampleBuffer else { return }
        let bridge = Unmanaged<EncoderCallbackBridge>.fromOpaque(refcon).takeUnretainedValue()
        bridge.handle(sampleBuffer)
    }
}

private final class EncoderCallbackBridge: @unchecked Sendable {
    private let handler: (CMSampleBuffer) -> Void

    init(handler: @escaping (CMSampleBuffer) -> Void) {
        self.handler = handler
    }

    func handle(_ sampleBuffer: CMSampleBuffer) {
        handler(sampleBuffer)
    }
}
