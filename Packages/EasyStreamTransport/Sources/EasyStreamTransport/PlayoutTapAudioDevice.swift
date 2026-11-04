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

    private var wantsLocalCapture = false
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

            let route = ProgramAudioRouteFlags.shared.snapshot()
            let byteCount = Int(frameCount) * Int(channels) * MemoryLayout<Int16>.size

            if route.feedLiveVideo {
                self.silence(audioBufferList, byteCount: byteCount)
                return noErr
            }

            if route.localCapture {
                ProgramAudioDelayBuffer.shared.setDelay(
                    milliseconds: route.delayMs,
                    sampleRate: sampleRate,
                    channels: UInt32(channels)
                )
                let delayed = ProgramAudioDelayBuffer.shared.pull(byteCount: byteCount)
                delayed.withUnsafeBytes { raw in
                    if let base = raw.baseAddress, let destination = audioBufferList.pointee.mBuffers.mData {
                        memcpy(destination, base, min(byteCount, raw.count))
                    }
                }
                self.tapPCM(from: audioBufferList, frameCount: frameCount, sampleRate: sampleRate, channels: UInt32(channels))
                return noErr
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
            guard status == noErr else { return status }

            if route.delayMs > 1 {
                guard let rendered = self.copyPCM(from: audioBufferList, byteCount: byteCount) else { return status }
                ProgramAudioDelayBuffer.shared.setDelay(
                    milliseconds: route.delayMs,
                    sampleRate: sampleRate,
                    channels: UInt32(channels)
                )
                ProgramAudioDelayBuffer.shared.push(rendered)
                let delayed = ProgramAudioDelayBuffer.shared.pull(byteCount: byteCount)
                delayed.withUnsafeBytes { raw in
                    if let base = raw.baseAddress, let destination = audioBufferList.pointee.mBuffers.mData {
                        memcpy(destination, base, min(byteCount, raw.count))
                    }
                }
            }

            self.tapPCM(from: audioBufferList, frameCount: frameCount, sampleRate: sampleRate, channels: UInt32(channels))
            return status
        }

        sourceNode = node
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            _isPlaying = true
            if wantsLocalCapture {
                installLocalTap()
            }
            return true
        } catch {
            EasyStreamLog.audio.error("Failed to start playout engine: \(error.localizedDescription)")
            return false
        }
    }

    func stopPlayout() -> Bool {
        guard _isPlaying else { return true }
        engine.inputNode.removeTap(onBus: 0)
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

    func setLocalCaptureEnabled(_ enabled: Bool) {
        wantsLocalCapture = enabled
        guard _isPlaying else { return }
        if enabled {
            installLocalTap()
        } else {
            engine.inputNode.removeTap(onBus: 0)
            ProgramAudioDelayBuffer.shared.reset()
        }
    }

    func apply(output choice: ProgramAudioOutputChoice) {
        let session = AVAudioSession.sharedInstance()
        do {
            switch choice {
            case .system:
                try session.overrideOutputAudioPort(.none)
            case .speaker:
                try session.overrideOutputAudioPort(.speaker)
            }
        } catch {
            EasyStreamLog.audio.error("Output route failed: \(error.localizedDescription)")
        }
    }

    func selectLocalInput(uid: String?) {
        let session = AVAudioSession.sharedInstance()
        guard let uid, let port = session.availableInputs?.first(where: { $0.uid == uid }) else {
            try? session.setPreferredInput(nil)
            return
        }
        try? session.setPreferredInput(port)
    }

    private func installLocalTap() {
        let input = engine.inputNode
        input.removeTap(onBus: 0)
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else { return }
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            guard let channel = buffer.floatChannelData else { return }
            let frames = Int(buffer.frameLength)
            let channels = Int(buffer.format.channelCount)
            guard frames > 0, channels > 0 else { return }
            var pcm = [Int16](repeating: 0, count: frames * channels)
            for frame in 0..<frames {
                for channelIndex in 0..<channels {
                    let unit = max(-1, min(1, channel[channelIndex][frame]))
                    pcm[frame * channels + channelIndex] = Int16(unit * Float(Int16.max))
                }
            }
            pcm.withUnsafeBufferPointer { ProgramAudioDelayBuffer.shared.push(Data(buffer: $0)) }
        }
    }

    private func silence(_ audioBufferList: UnsafeMutablePointer<AudioBufferList>, byteCount: Int) {
        if let destination = audioBufferList.pointee.mBuffers.mData {
            memset(destination, 0, byteCount)
        }
    }

    private func copyPCM(from audioBufferList: UnsafeMutablePointer<AudioBufferList>, byteCount: Int) -> Data? {
        guard let data = audioBufferList.pointee.mBuffers.mData, byteCount > 0 else { return nil }
        return Data(bytes: data, count: byteCount)
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
        ProgramAudioLevelBus.note(pcm: pcm)
        ProgramAudioTapRegistry.deliver(pcm: pcm, sampleRate: sampleRate, channels: channels, frames: frameCount)
    }
}

enum ProgramAudioDeviceRegistry {
    static let sharedDevice = PlayoutTapAudioDevice()
}
#endif
