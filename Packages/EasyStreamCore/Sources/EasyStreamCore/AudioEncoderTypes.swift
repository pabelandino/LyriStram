import Foundation
import CoreMedia

public struct AudioEncoderConfiguration: Sendable, Equatable, Codable {
    public var sampleRate: Double
    public var channelCount: UInt32
    public var bitrate: Int

    public init(
        sampleRate: Double = 48_000,
        channelCount: UInt32 = 2,
        bitrate: Int = 128_000
    ) {
        self.sampleRate = sampleRate
        self.channelCount = channelCount
        self.bitrate = bitrate
    }

    public static let broadcastAAC = AudioEncoderConfiguration()
}

public struct EncodedAudioSample: Sendable {
    public let data: Data
    public let presentationTime: CMTime
    public let packetDescription: AudioStreamPacketDescription?

    public init(
        data: Data,
        presentationTime: CMTime,
        packetDescription: AudioStreamPacketDescription? = nil
    ) {
        self.data = data
        self.presentationTime = presentationTime
        self.packetDescription = packetDescription
    }
}

public struct AudioStreamPacketDescription: Sendable, Equatable {
    public let byteOffset: Int
    public let byteLength: Int

    public init(byteOffset: Int, byteLength: Int) {
        self.byteOffset = byteOffset
        self.byteLength = byteLength
    }
}

public struct AudioEncoderStats: Sendable, Equatable {
    public var packetsEncoded: Int
    public var bytesEncoded: Int
    public var configuredBitrate: Int
    public var isRunning: Bool

    public init(
        packetsEncoded: Int = 0,
        bytesEncoded: Int = 0,
        configuredBitrate: Int = 0,
        isRunning: Bool = false
    ) {
        self.packetsEncoded = packetsEncoded
        self.bytesEncoded = bytesEncoded
        self.configuredBitrate = configuredBitrate
        self.isRunning = isRunning
    }
}

/// Receives PCM tapped from WebRTC program playout on the Director.
public enum ProgramAudioTapRegistry: Sendable {
    private final class Storage: @unchecked Sendable {
        var handler: (@Sendable (Data, Double, UInt32, UInt32) -> Void)?
    }

    private static let storage = Storage()

    public static func setHandler(_ handler: (@Sendable (Data, Double, UInt32, UInt32) -> Void)?) {
        storage.handler = handler
    }

    public static func deliver(pcm: Data, sampleRate: Double, channels: UInt32, frames: UInt32) {
        storage.handler?(pcm, sampleRate, channels, frames)
    }
}
