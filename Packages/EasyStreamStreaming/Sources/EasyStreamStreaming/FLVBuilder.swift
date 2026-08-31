import Foundation
import CoreMedia
import CoreVideo
import EasyStreamCore

enum FLVBuilder {
    static let aacSoundHeader: UInt8 = 0xAF

    static func makeAACSequenceHeader(sampleRate: Int, channels: Int) -> Data {
        var payload = Data([aacSoundHeader, 0x00])
        payload.append(makeAudioSpecificConfig(sampleRate: sampleRate, channels: channels))
        return payload
    }

    static func makeAACFrame(_ frame: Data) -> Data {
        var payload = Data([aacSoundHeader, 0x01])
        payload.append(frame)
        return payload
    }

    static func makeH264SequenceHeader(from formatDescription: CMFormatDescription) -> Data? {
        guard let avcc = makeAVCDecoderConfigurationRecord(from: formatDescription) else { return nil }
        var payload = Data()
        payload.append(0x17) // keyframe + AVC
        payload.append(0x00) // AVC sequence header
        payload.append(contentsOf: [0x00, 0x00, 0x00]) // composition time
        payload.append(avcc)
        return payload
    }

    static func makeH264Frame(sample: EncodedVideoSample) -> Data {
        var payload = Data()
        payload.append(sample.isKeyframe ? 0x17 : 0x27)
        payload.append(0x01) // AVC NALU
        payload.append(contentsOf: [0x00, 0x00, 0x00]) // composition time
        payload.append(sample.data)
        return payload
    }

    static func timestampMs(from time: CMTime, origin: CMTime) -> UInt32 {
        let delta = CMTimeSubtract(time, origin)
        let seconds = CMTimeGetSeconds(delta)
        guard seconds.isFinite, seconds >= 0 else { return 0 }
        return UInt32(seconds * 1000)
    }

    private static func makeAudioSpecificConfig(sampleRate: Int, channels: Int) -> Data {
        let sampleRateIndex = sampleRateIndex(for: sampleRate)
        let profile: UInt8 = 2
        let channelConfig = UInt8(channels)
        return Data([
            (profile << 3) | UInt8(sampleRateIndex >> 1),
            ((UInt8(sampleRateIndex) & 1) << 7) | (channelConfig << 3),
        ])
    }

    private static func sampleRateIndex(for sampleRate: Int) -> Int {
        switch sampleRate {
        case 96_000: 0
        case 88_200: 1
        case 64_000: 2
        case 48_000: 3
        case 44_100: 4
        case 32_000: 5
        case 24_000: 6
        case 22_050: 7
        case 16_000: 8
        case 12_000: 9
        case 11_025: 10
        case 8_000: 11
        default: 3
        }
    }

    private static func makeAVCDecoderConfigurationRecord(from formatDescription: CMFormatDescription) -> Data? {
        var spsPointer: UnsafePointer<UInt8>?
        var ppsPointer: UnsafePointer<UInt8>?
        var spsSize = 0
        var ppsSize = 0

        let spsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(
            formatDescription,
            parameterSetIndex: 0,
            parameterSetPointerOut: &spsPointer,
            parameterSetSizeOut: &spsSize,
            parameterSetCountOut: nil,
            nalUnitHeaderLengthOut: nil
        )
        let ppsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(
            formatDescription,
            parameterSetIndex: 1,
            parameterSetPointerOut: &ppsPointer,
            parameterSetSizeOut: &ppsSize,
            parameterSetCountOut: nil,
            nalUnitHeaderLengthOut: nil
        )

        guard spsStatus == noErr, ppsStatus == noErr,
              let spsPointer, let ppsPointer, spsSize > 0, ppsSize > 0 else {
            return nil
        }

        var avcc = Data()
        avcc.append(0x01)
        avcc.append(spsPointer[1]) // profile
        avcc.append(spsPointer[2]) // compatibility
        avcc.append(spsPointer[3]) // level
        avcc.append(0xFF) // 4-byte length NALUs

        avcc.append(0xE1)
        avcc.append(UInt8((spsSize >> 8) & 0xFF))
        avcc.append(UInt8(spsSize & 0xFF))
        avcc.append(Data(bytes: spsPointer, count: spsSize))

        avcc.append(0x01)
        avcc.append(UInt8((ppsSize >> 8) & 0xFF))
        avcc.append(UInt8(ppsSize & 0xFF))
        avcc.append(Data(bytes: ppsPointer, count: ppsSize))

        return avcc
    }
}
