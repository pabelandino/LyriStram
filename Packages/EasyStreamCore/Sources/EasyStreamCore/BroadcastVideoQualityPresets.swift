import Foundation

public enum BroadcastPlatform: String, Codable, Sendable, CaseIterable, Hashable {
    case youtube
    case facebook
    case rtmp

    public var shortLabel: String {
        switch self {
        case .youtube: "YouTube"
        case .facebook: "Facebook"
        case .rtmp: "RTMP"
        }
    }
}

/// LAN stream dimensions used between cameras and the director.
public struct BroadcastStreamSpec: Codable, Sendable, Equatable {
    public var width: Int32
    public var height: Int32
    public var frameRate: Int32
    public var maxBitrateBps: Int

    public init(width: Int32, height: Int32, frameRate: Int32, maxBitrateBps: Int) {
        self.width = width
        self.height = height
        self.frameRate = frameRate
        self.maxBitrateBps = maxBitrateBps
    }

    public var displayLabel: String {
        "\(width)×\(height) · \(frameRate) fps"
    }
}

/// Local PROG monitor quality — what cameras send while on program.
public enum ProgramMonitorPreset: String, Codable, CaseIterable, Identifiable, Sendable {
    case light360
    case economy540
    case balanced720
    case full1080

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .light360: "360p ligero"
        case .economy540: "540p ahorro"
        case .balanced720: "720p equilibrado"
        case .full1080: "1080p completo"
        }
    }

    public var streamSpec: BroadcastStreamSpec {
        switch self {
        case .light360:
            BroadcastStreamSpec(width: 640, height: 360, frameRate: 20, maxBitrateBps: 900_000)
        case .economy540:
            BroadcastStreamSpec(width: 960, height: 540, frameRate: 20, maxBitrateBps: 1_200_000)
        case .balanced720:
            BroadcastStreamSpec(width: 1_280, height: 720, frameRate: 24, maxBitrateBps: 2_500_000)
        case .full1080:
            BroadcastStreamSpec(width: 1_920, height: 1_080, frameRate: 30, maxBitrateBps: 5_000_000)
        }
    }

    public var detail: String {
        "Monitor PROG · \(streamSpec.displayLabel)"
    }
}

/// Preview tile LAN quality — always lower than program to save CPU.
public enum PreviewTilePreset: String, Codable, CaseIterable, Identifiable, Sendable {
    case economy
    case standard

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .economy: "Tiles 360p"
        case .standard: "Tiles 360p fluido"
        }
    }

    public var streamSpec: BroadcastStreamSpec {
        switch self {
        case .economy:
            BroadcastStreamSpec(width: 640, height: 360, frameRate: 15, maxBitrateBps: 600_000)
        case .standard:
            BroadcastStreamSpec(width: 640, height: 360, frameRate: 20, maxBitrateBps: 900_000)
        }
    }
}

/// RTMP / social output — H.264 encoder preset.
public enum StreamOutputPreset: String, Codable, CaseIterable, Identifiable, Sendable {
    case stream540p30
    case facebook720p30
    case youtube720p30
    case youtube720p60
    case facebook1080p30
    case youtube1080p30
    case youtube1080p60

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .stream540p30: "540p · 30 fps"
        case .facebook720p30: "720p · 30 fps"
        case .youtube720p30: "720p · 30 fps"
        case .youtube720p60: "720p · 60 fps"
        case .facebook1080p30: "1080p · 30 fps"
        case .youtube1080p30: "1080p · 30 fps"
        case .youtube1080p60: "1080p · 60 fps"
        }
    }

    public var platforms: [BroadcastPlatform] {
        switch self {
        case .stream540p30:
            [.rtmp, .youtube, .facebook]
        case .facebook720p30:
            [.facebook, .youtube]
        case .youtube720p30:
            [.youtube, .facebook]
        case .youtube720p60:
            [.youtube]
        case .facebook1080p30:
            [.facebook, .youtube]
        case .youtube1080p30:
            [.youtube, .facebook]
        case .youtube1080p60:
            [.youtube]
        }
    }

    public var encoderConfiguration: VideoEncoderConfiguration {
        switch self {
        case .stream540p30:
            VideoEncoderConfiguration(
                width: 960, height: 540, frameRate: 30,
                averageBitrate: 2_000_000, maxKeyFrameInterval: 60
            )
        case .facebook720p30, .youtube720p30:
            VideoEncoderConfiguration(
                width: 1_280, height: 720, frameRate: 30,
                averageBitrate: 4_500_000, maxKeyFrameInterval: 60
            )
        case .youtube720p60:
            VideoEncoderConfiguration(
                width: 1_280, height: 720, frameRate: 60,
                averageBitrate: 6_000_000, maxKeyFrameInterval: 120
            )
        case .facebook1080p30, .youtube1080p30:
            VideoEncoderConfiguration(
                width: 1_920, height: 1_080, frameRate: 30,
                averageBitrate: 6_000_000, maxKeyFrameInterval: 60
            )
        case .youtube1080p60:
            VideoEncoderConfiguration(
                width: 1_920, height: 1_080, frameRate: 60,
                averageBitrate: 9_000_000, maxKeyFrameInterval: 120
            )
        }
    }

    public var detail: String {
        let config = encoderConfiguration
        let mbps = Double(config.averageBitrate) / 1_000_000
        let platforms = platforms.map(\.shortLabel).joined(separator: " · ")
        return "\(config.width)×\(config.height) · \(config.frameRate) fps · \(String(format: "%.1f", mbps)) Mbps · \(platforms)"
    }
}
