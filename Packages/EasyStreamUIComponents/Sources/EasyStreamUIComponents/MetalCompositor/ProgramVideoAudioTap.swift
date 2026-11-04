import AVFoundation
import CoreMedia
import EasyStreamCore

/// Copies a library video's audio to the speakers and to the program encoder.
enum ProgramVideoAudioTap {
    static func install(on item: AVPlayerItem, track: AVAssetTrack) {
        let context = TapBox()
        var callbacks = MTAudioProcessingTapCallbacks(
            version: kMTAudioProcessingTapCallbacksVersion_0,
            clientInfo: Unmanaged.passRetained(context).toOpaque(),
            init: { _, clientInfo, storageOut in
                storageOut.pointee = clientInfo
            },
            finalize: { tap in
                Unmanaged<TapBox>.fromOpaque(MTAudioProcessingTapGetStorage(tap)).release()
            },
            prepare: { tap, _, format in
                let box = Unmanaged<TapBox>.fromOpaque(MTAudioProcessingTapGetStorage(tap)).takeUnretainedValue()
                box.prepare(format.pointee)
            },
            unprepare: { _ in },
            process: { tap, frames, _, bufferList, framesOut, flagsOut in
                let box = Unmanaged<TapBox>.fromOpaque(MTAudioProcessingTapGetStorage(tap)).takeUnretainedValue()
                box.process(
                    tap: tap,
                    frames: frames,
                    bufferList: bufferList,
                    framesOut: framesOut,
                    flagsOut: flagsOut
                )
            }
        )

        var tap: MTAudioProcessingTap?
        guard MTAudioProcessingTapCreate(
            kCFAllocatorDefault,
            &callbacks,
            kMTAudioProcessingTapCreationFlag_PostEffects,
            &tap
        ) == noErr, let tap else { return }

        let parameters = AVMutableAudioMixInputParameters(track: track)
        parameters.audioTapProcessor = tap
        let mix = AVMutableAudioMix()
        mix.inputParameters = [parameters]
        item.audioMix = mix
    }
}

private final class TapBox {
    var sampleRate: Double = 48_000
    var channels: UInt32 = 2
    var isFloat = true
    var bits: UInt32 = 32

    func prepare(_ format: AudioStreamBasicDescription) {
        sampleRate = format.mSampleRate
        channels = max(1, format.mChannelsPerFrame)
        isFloat = format.mFormatFlags & kAudioFormatFlagIsFloat != 0
        bits = format.mBitsPerChannel == 0 ? 32 : format.mBitsPerChannel
    }

    func process(
        tap: MTAudioProcessingTap,
        frames: CMItemCount,
        bufferList: UnsafeMutablePointer<AudioBufferList>,
        framesOut: UnsafeMutablePointer<CMItemCount>,
        flagsOut: UnsafeMutablePointer<MTAudioProcessingTapFlags>
    ) {
        let status = MTAudioProcessingTapGetSourceAudio(
            tap,
            frames,
            bufferList,
            flagsOut,
            nil,
            framesOut
        )
        guard status == noErr else { return }

        let route = ProgramAudioRouteFlags.shared.snapshot()
        guard route.feedLiveVideo else {
            silence(bufferList)
            return
        }

        guard let pcm = int16Interleaved(bufferList, frames: framesOut.pointee) else { return }
        ProgramAudioLevelBus.note(pcm: pcm)
        ProgramAudioTapRegistry.deliver(
            pcm: pcm,
            sampleRate: sampleRate,
            channels: channels,
            frames: UInt32(framesOut.pointee)
        )
    }

    private func silence(_ bufferList: UnsafeMutablePointer<AudioBufferList>) {
        let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
        for buffer in buffers {
            guard let data = buffer.mData else { continue }
            memset(data, 0, Int(buffer.mDataByteSize))
        }
    }

    private func int16Interleaved(
        _ bufferList: UnsafeMutablePointer<AudioBufferList>,
        frames: CMItemCount
    ) -> Data? {
        let frameCount = Int(frames)
        guard frameCount > 0 else { return nil }
        let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
        guard let first = buffers.first, let data = first.mData else { return nil }

        if !isFloat, bits == 16 {
            let byteCount = frameCount * Int(channels) * MemoryLayout<Int16>.size
            return Data(bytes: data, count: min(byteCount, Int(first.mDataByteSize)))
        }

        var output = [Int16](repeating: 0, count: frameCount * Int(channels))
        if buffers.count == 1 {
            let samples = data.assumingMemoryBound(to: Float.self)
            let count = min(output.count, Int(first.mDataByteSize) / MemoryLayout<Float>.size)
            for index in 0..<count {
                let unit = max(-1, min(1, samples[index]))
                output[index] = Int16(unit * Float(Int16.max))
            }
        } else {
            for channel in 0..<min(Int(channels), buffers.count) {
                guard let channelData = buffers[channel].mData else { continue }
                let samples = channelData.assumingMemoryBound(to: Float.self)
                let available = Int(buffers[channel].mDataByteSize) / MemoryLayout<Float>.size
                for frame in 0..<min(frameCount, available) {
                    let unit = max(-1, min(1, samples[frame]))
                    output[frame * Int(channels) + channel] = Int16(unit * Float(Int16.max))
                }
            }
        }
        return output.withUnsafeBufferPointer { Data(buffer: $0) }
    }
}
