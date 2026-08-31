import AVFoundation
import Foundation
import EasyStreamCore

#if os(iOS)
import WebRTC
#endif

#if os(iOS)
/// Custom WebRTC audio device that plays remote program audio and taps PCM for AAC encoding.
final class PlayoutTapAudioDevice: NSObject, RTCAudioDevice {
    private var delegate: RTCAudioDeviceDelegate?
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var outputFormat: AVAudioFormat?

    private var _isInitialized = false
    private var _isPlayoutInitialized = false
    private var _isPlaying = false
    private var _isRecordingInitialized = true
    private var _isRecording = false

    var deviceInputSampleRate: Double {
        delegate?.preferredInputSampleRate ?? 48_000
    }

    var inputIOBufferDuration: TimeInterval {
        delegate?.preferredInputIOBufferDuration ?? 0.01
    }

    var inputNumberOfChannels: Int {
        1
    }

    var inputLatency: TimeInterval { 0 }

    var deviceOutputSampleRate: Double {
        delegate?.preferredOutputSampleRate ?? 48_000
    }

    var outputIOBufferDuration: TimeInterval {
        delegate?.preferredOutputIOBufferDuration ?? 0.01
    }

    var outputNumberOfChannels: Int {
        2
    }

    var outputLatency: TimeInterval { 0 }

    var isInitialized: Bool { _isInitialized }

    var isPlayoutInitialized: Bool { _isPlayoutInitialized }

    var isPlaying: Bool { _isPlaying }

    var isRecordingInitialized: Bool { _isRecordingInitialized }

    var isRecording: Bool { _isRecording }

    func initialize(with delegate: RTCAudioDeviceDelegate) -> Bool {
        self.delegate = delegate
        _isInitialized = true
        configureAudioSession()
        return true
    }

    func terminateDevice() -> Bool {
        _ = stopPlayout()
        sourceNode = nil
        delegate = nil
        _isInitialized = false
        _isPlayoutInitialized = false
        return true
    }

    func initializePlayout() -> Bool {
        _isPlayoutInitialized = true
        return true
    }

    func startPlayout() -> Bool {
        guard let delegate else { return false }
        guard !_isPlaying else { return true }

        let sampleRate = delegate.preferredOutputSampleRate
        let channels = AVAudioChannelCount(max(outputNumberOfChannels, 1))
        guard let format = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: sampleRate,
            channels: channels,
            interleaved: true
        ) else {
            return false
        }

        outputFormat = format

        let node = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self, let delegate = self.delegate else {
                return kAudioUnitErr_Uninitialized
            }

            var flags: AudioUnitRenderActionFlags = []
            var timestamp = AudioTimeStamp()
            let status = delegate.getPlayoutData(
                &flags,
                &timestamp,
                0,
                frameCount,
                audioBufferList
            )

            if status == noErr {
                self.tapPCM(from: audioBufferList, frameCount: frameCount, sampleRate: sampleRate, channels: UInt32(channels))
            }

            return status
        }

        sourceNode = node
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            _isPlaying = true
            return true
        } catch {
            EasyStreamLog.audio.error("Failed to start playout engine: \(error.localizedDescription)")
            return false
        }
    }

    func stopPlayout() -> Bool {
        guard _isPlaying else { return true }
        engine.stop()
        if let sourceNode {
            engine.disconnectNodeOutput(sourceNode)
            engine.detach(sourceNode)
        }
        sourceNode = nil
        _isPlaying = false
        return true
    }

    func initializeRecording() -> Bool {
        _isRecordingInitialized = true
        return true
    }

    func startRecording() -> Bool {
        _isRecording = false
        return true
    }

    func stopRecording() -> Bool {
        _isRecording = false
        return true
    }

    private func configureAudioSession() {
#if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .videoChat, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            EasyStreamLog.audio.error("Audio session setup failed: \(error.localizedDescription)")
        }
#endif
    }

    private func tapPCM(from audioBufferList: UnsafeMutablePointer<AudioBufferList>, frameCount: UInt32, sampleRate: Double, channels: UInt32) {
        let buffer = audioBufferList.pointee.mBuffers
        guard let data = buffer.mData else { return }
        let byteCount = Int(buffer.mDataByteSize)
        guard byteCount > 0 else { return }

        let pcm = Data(bytes: data, count: byteCount)
        ProgramAudioTapRegistry.deliver(pcm: pcm, sampleRate: sampleRate, channels: channels, frames: frameCount)
    }
}

enum ProgramAudioDeviceRegistry {
    static let sharedDevice = PlayoutTapAudioDevice()
}
#endif
