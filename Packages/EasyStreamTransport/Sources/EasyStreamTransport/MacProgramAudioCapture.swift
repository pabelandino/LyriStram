import AudioToolbox
import AVFoundation
import EasyStreamCore
import Foundation
import OSLog

#if os(macOS)

/// Captures a chosen audio interface on the Mac and feeds the program encoder.
@MainActor
final class MacProgramAudioCapture {
    static let shared = MacProgramAudioCapture()

    private var engine: AVAudioEngine?
    private var activeUID: String?

    private init() {}

    func setInput(uid: String?) {
        guard uid != activeUID else { return }
        stop()
        guard let uid, let deviceID = MacAudioDeviceCatalog.deviceID(uid: uid) else { return }

        let engine = AVAudioEngine()
        let input = engine.inputNode
        var hardwareID = deviceID
        let propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        if let unit = input.audioUnit {
            AudioUnitSetProperty(
                unit,
                kAudioOutputUnitProperty_CurrentDevice,
                kAudioUnitScope_Global,
                0,
                &hardwareID,
                propertySize
            )
        }

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
            let data = pcm.withUnsafeBufferPointer { Data(buffer: $0) }
            ProgramAudioLevelBus.note(pcm: data)
            ProgramAudioTapRegistry.deliver(
                pcm: data,
                sampleRate: buffer.format.sampleRate,
                channels: UInt32(channels),
                frames: UInt32(frames)
            )
        }

        do {
            try engine.start()
            self.engine = engine
            activeUID = uid
        } catch {
            input.removeTap(onBus: 0)
            EasyStreamLog.audio.error("Interface capture failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func stop() {
        engine?.inputNode.removeTap(onBus: 0)
        engine?.stop()
        engine = nil
        activeUID = nil
        ProgramAudioDelayBuffer.shared.reset()
    }
}
#endif
