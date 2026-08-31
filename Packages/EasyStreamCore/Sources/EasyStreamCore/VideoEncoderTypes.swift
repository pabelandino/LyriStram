import Foundation
import CoreMedia

public struct VideoEncoderConfiguration: Sendable, Equatable, Codable {
    public var width: Int32
    public var height: Int32
    public var frameRate: Int32
    public var averageBitrate: Int
    public var maxKeyFrameInterval: Int

    public init(
        width: Int32 = 1920,
        height: Int32 = 1080,
        frameRate: Int32 = 30,
        averageBitrate: Int = 6_000_000,
        maxKeyFrameInterval: Int = 60
    ) {
        self.width = width
        self.height = height
        self.frameRate = frameRate
        self.averageBitrate = averageBitrate
        self.maxKeyFrameInterval = maxKeyFrameInterval
    }

    public static let broadcast1080p30 = VideoEncoderConfiguration()
}

public struct EncodedVideoSample: Sendable {
    public let data: Data
    public let presentationTime: CMTime
    public let decodeTime: CMTime?
    public let isKeyframe: Bool
    public let formatDescription: CMFormatDescription?

    public init(
        data: Data,
        presentationTime: CMTime,
        decodeTime: CMTime? = nil,
        isKeyframe: Bool,
        formatDescription: CMFormatDescription?
    ) {
        self.data = data
        self.presentationTime = presentationTime
        self.decodeTime = decodeTime
        self.isKeyframe = isKeyframe
        self.formatDescription = formatDescription
    }
}

public struct VideoEncoderStats: Sendable, Equatable {
    public var framesEncoded: Int
    public var keyframesEncoded: Int
    public var bytesEncoded: Int
    public var configuredBitrate: Int
    public var isRunning: Bool

    public init(
        framesEncoded: Int = 0,
        keyframesEncoded: Int = 0,
        bytesEncoded: Int = 0,
        configuredBitrate: Int = 0,
        isRunning: Bool = false
    ) {
        self.framesEncoded = framesEncoded
        self.keyframesEncoded = keyframesEncoded
        self.bytesEncoded = bytesEncoded
        self.configuredBitrate = configuredBitrate
        self.isRunning = isRunning
    }

    public var estimatedBitrateKbps: Int {
        guard framesEncoded > 0 else { return 0 }
        // Rough average over session; refined once RTMP ships.
        return (bytesEncoded * 8) / max(framesEncoded, 1) * 30 / 1000
    }
}
