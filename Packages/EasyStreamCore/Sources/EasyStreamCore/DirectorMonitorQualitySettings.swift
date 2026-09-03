import Foundation

/// Director video quality — local PROG monitor vs network stream output.
public struct DirectorMonitorQualitySettings: Codable, Sendable, Equatable {
    public var progPreset: ProgramMonitorPreset
    public var previewPreset: PreviewTilePreset
    public var outputPreset: StreamOutputPreset
    /// Pre-decode the take target on the director bus before Aire (smoother cuts, higher CPU).
    public var prefetchTakeTarget: Bool

    public init(
        progPreset: ProgramMonitorPreset = .balanced720,
        previewPreset: PreviewTilePreset = .standard,
        outputPreset: StreamOutputPreset = .youtube1080p30,
        prefetchTakeTarget: Bool = true
    ) {
        self.progPreset = progPreset
        self.previewPreset = previewPreset
        self.outputPreset = outputPreset
        self.prefetchTakeTarget = prefetchTakeTarget
    }

    public var outputEncoderConfiguration: VideoEncoderConfiguration {
        outputPreset.encoderConfiguration
    }

    private enum CodingKeys: String, CodingKey {
        case progPreset
        case previewPreset
        case outputPreset
        case prefetchTakeTarget
        case tier
    }

    private enum LegacyTier: String, Codable {
        case economy
        case balanced
        case high
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prefetchTakeTarget = try container.decodeIfPresent(Bool.self, forKey: .prefetchTakeTarget) ?? true

        if let prog = try container.decodeIfPresent(ProgramMonitorPreset.self, forKey: .progPreset) {
            progPreset = prog
            previewPreset = try container.decodeIfPresent(PreviewTilePreset.self, forKey: .previewPreset) ?? .standard
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
