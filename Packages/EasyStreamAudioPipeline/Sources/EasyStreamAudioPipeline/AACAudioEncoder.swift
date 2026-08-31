import Foundation
import AVFoundation
import CoreMedia
import EasyStreamCore

public enum AudioEncoderError: Error, Sendable {
    case converterCreationFailed
    case conversionFailed
    case invalidInput
}

/// AAC-LC encoder for broadcast program audio.
public actor AACAudioEncoder {
    private var configuration = AudioEncoderConfiguration.broadcastAAC
    private var converter: AVAudioConverter?
    private var inputFormat: AVAudioFormat?
    private var outputFormat: AVAudioFormat?
    private var continuation: AsyncStream<EncodedAudioSample>.Continuation?
    private var stats = AudioEncoderStats()
    private var sampleCounter: Int64 = 0

    public init() {}

    public func encodedSamples() -> AsyncStream<EncodedAudioSample> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.stop() }
            }
        }
    }

    public func currentStats() -> AudioEncoderStats {
        stats
    }

    public func start(configuration: AudioEncoderConfiguration = .broadcastAAC) throws {
        self.configuration = configuration
        stats = AudioEncoderStats(configuredBitrate: configuration.bitrate, isRunning: true)
        sampleCounter = 0
        converter = nil
        inputFormat = nil
        outputFormat = nil
    }

    public func encode(
        pcm: Data,
        sampleRate: Double,
        channels: UInt32,
        frames: UInt32
    ) throws {
        guard frames > 0, !pcm.isEmpty else { throw AudioEncoderError.invalidInput }

        try ensureConverter(sampleRate: sampleRate, channels: channels)

        guard let converter, let inputFormat, let outputFormat else {
            throw AudioEncoderError.converterCreationFailed
        }

        let bytesPerFrame = Int(channels) * MemoryLayout<Int16>.size
        let expectedBytes = Int(frames) * bytesPerFrame
        guard pcm.count >= expectedBytes else { throw AudioEncoderError.invalidInput }

        let presentationTime = CMTime(value: sampleCounter, timescale: CMTimeScale(sampleRate))
        sampleCounter += Int64(frames)

        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: frames) else {
            throw AudioEncoderError.converterCreationFailed
        }
        pcmBuffer.frameLength = frames

        pcm.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress,
                  let channelData = pcmBuffer.int16ChannelData else { return }
            memcpy(channelData[0], base, expectedBytes)
        }

        let maximumPacketSize = converter.maximumOutputPacketSize
        let compressedBuffer = AVAudioCompressedBuffer(
            format: outputFormat,
            packetCapacity: 1,
            maximumPacketSize: maximumPacketSize
        )

        var error: NSError?
        let status = converter.convert(to: compressedBuffer, error: &error) { _, outStatus in
            outStatus.pointee = .haveData
            return pcmBuffer
        }

        guard status != .error, compressedBuffer.byteLength > 0 else {
            if let error { EasyStreamLog.audio.error("AAC conversion failed: \(error.localizedDescription)") }
            throw AudioEncoderError.conversionFailed
        }

        let encoded = Data(bytes: compressedBuffer.data, count: Int(compressedBuffer.byteLength))
        stats.packetsEncoded += 1
        stats.bytesEncoded += encoded.count

        continuation?.yield(EncodedAudioSample(
            data: encoded,
            presentationTime: presentationTime
        ))
    }

    public func stop() {
        converter = nil
        inputFormat = nil
        outputFormat = nil
        stats.isRunning = false
        continuation?.finish()
        continuation = nil
    }

    private func ensureConverter(sampleRate: Double, channels: UInt32) throws {
        guard converter == nil else { return }

        guard let inputFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: sampleRate,
            channels: AVAudioChannelCount(channels),
            interleaved: true
        ) else {
            throw AudioEncoderError.converterCreationFailed
        }

        var outputDescription = AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatMPEG4AAC,
            mFormatFlags: 0,
            mBytesPerPacket: 0,
            mFramesPerPacket: 1024,
            mBytesPerFrame: 0,
            mChannelsPerFrame: channels,
            mBitsPerChannel: 0,
            mReserved: 0
        )

        guard let outputFormat = AVAudioFormat(streamDescription: &outputDescription) else {
            throw AudioEncoderError.converterCreationFailed
        }

        guard let converter = AVAudioConverter(from: inputFormat, to: outputFormat) else {
            throw AudioEncoderError.converterCreationFailed
        }

        converter.bitRate = configuration.bitrate
        self.inputFormat = inputFormat
        self.outputFormat = outputFormat
        self.converter = converter

        EasyStreamLog.audio.info("AAC encoder ready at \(sampleRate)Hz · \(channels)ch")
    }
}
