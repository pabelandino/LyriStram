import Foundation

/// Director video quality — local PROG monitor vs network stream output.
public struct DirectorMonitorQualitySettings: Codable, Sendable, Equatable {
    public var progPreset: ProgramMonitorPreset
    public var previewPreset: PreviewTilePreset
    public var outputPreset: StreamOutputPreset
    /// Master switch — applies conservative LAN + GPU defaults for laptops and iPads.
    public var energySaverMode: Bool
    /// Pre-decode the take target on the director bus before Aire (smoother cuts, higher CPU).
    public var prefetchTakeTarget: Bool
    /// When true, idle cameras stop sending video — keeps director CPU flat as N grows.
    public var pauseIdleCameraStreams: Bool

    public init(
        progPreset: ProgramMonitorPreset = .light360,
        previewPreset: PreviewTilePreset = .minimal,
        outputPreset: StreamOutputPreset = .youtube1080p30,
        energySaverMode: Bool = true,
        prefetchTakeTarget: Bool = false,
        pauseIdleCameraStreams: Bool = true
    ) {
        self.progPreset = progPreset
        self.previewPreset = previewPreset
        self.outputPreset = outputPreset
        self.energySaverMode = energySaverMode
        self.prefetchTakeTarget = prefetchTakeTarget
        self.pauseIdleCameraStreams = pauseIdleCameraStreams
    }

    public var outputEncoderConfiguration: VideoEncoderConfiguration {
        outputPreset.encoderConfiguration
    }

    private enum CodingKeys: String, CodingKey {
        case progPreset
        case previewPreset
        case outputPreset
        case prefetchTakeTarget
        case pauseIdleCameraStreams
        case energySaverMode
        case tier
    }

    private enum LegacyTier: String, Codable {
        case economy
        case balanced
        case high
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prefetchTakeTarget = try container.decodeIfPresent(Bool.self, forKey: .prefetchTakeTarget) ?? false
        pauseIdleCameraStreams = try container.decodeIfPresent(Bool.self, forKey: .pauseIdleCameraStreams) ?? true
        energySaverMode = try container.decodeIfPresent(Bool.self, forKey: .energySaverMode) ?? false

        if let prog = try container.decodeIfPresent(ProgramMonitorPreset.self, forKey: .progPreset) {
            progPreset = prog
            previewPreset = try container.decodeIfPresent(PreviewTilePreset.self, forKey: .previewPreset) ?? .economy
            outputPreset = try container.decodeIfPresent(StreamOutputPreset.self, forKey: .outputPreset) ?? .youtube1080p30
            return
        }

        let legacyTier = try container.decodeIfPresent(LegacyTier.self, forKey: .tier) ?? .balanced
        switch legacyTier {
        case .economy:
            progPreset = .economy540
            previewPreset = .economy
            outputPreset = .stream540p30
        case .balanced:
            progPreset = .balanced720
            previewPreset = .standard
            outputPreset = .youtube720p30
        case .high:
            progPreset = .full1080
            previewPreset = .standard
            outputPreset = .youtube1080p30
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(progPreset, forKey: .progPreset)
        try container.encode(previewPreset, forKey: .previewPreset)
        try container.encode(outputPreset, forKey: .outputPreset)
        try container.encode(prefetchTakeTarget, forKey: .prefetchTakeTarget)
        try container.encode(pauseIdleCameraStreams, forKey: .pauseIdleCameraStreams)
        try container.encode(energySaverMode, forKey: .energySaverMode)
    }

    /// Applies conservative toggles while energy saver is on (does not override PROG preset the operator chose).
    public func effectiveSettings() -> DirectorMonitorQualitySettings {
        guard energySaverMode else { return self }
        var copy = self
        copy.prefetchTakeTarget = false
        copy.pauseIdleCameraStreams = true
        if copy.previewPreset == .standard {
            copy.previewPreset = .economy
        }
        return copy
    }
}

public enum DirectorMonitorQualityPreferencesStore {
    private static let key = "com.easystream.directorMonitorQuality"

    public static func load() -> DirectorMonitorQualitySettings {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let settings = try? JSONDecoder().decode(DirectorMonitorQualitySettings.self, from: data)
        else {
            return DirectorMonitorQualitySettings()
        }
        return settings
    }

    public static func save(_ settings: DirectorMonitorQualitySettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

// Backward-compatible typealiases for transport helpers.
public extension DirectorMonitorQualitySettings {
    typealias StreamSpec = BroadcastStreamSpec
}
