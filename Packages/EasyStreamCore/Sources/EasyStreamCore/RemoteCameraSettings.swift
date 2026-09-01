import Foundation

/// Persisted + remotely controllable camera settings.
public struct RemoteCameraSettings: Codable, Sendable, Equatable {
    public var isMuted: Bool
    public var zoomFactor: Double
    public var exposureBias: Float
    public var whiteBalance: String
    public var activeLens: String

    public init(
        isMuted: Bool = false,
        zoomFactor: Double = 1,
        exposureBias: Float = 0,
        whiteBalance: String = "auto",
        activeLens: String = "wide"
    ) {
        self.isMuted = isMuted
        self.zoomFactor = zoomFactor
        self.exposureBias = exposureBias
        self.whiteBalance = whiteBalance
        self.activeLens = activeLens
    }
}

public enum RemoteLensOption: String, Sendable, CaseIterable, Identifiable {
    case ultraWide
    case wide
    case telephoto
    case front

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .ultraWide: "Ultra gran angular"
        case .wide: "Gran angular"
        case .telephoto: "Teleobjetivo"
        case .front: "Frontal"
        }
    }
}

public enum RemoteWhiteBalanceOption: String, Sendable, CaseIterable, Identifiable {
    case auto
    case locked
    case warm
    case neutral
    case cool

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .auto: "Automático"
        case .locked: "Bloqueado"
        case .warm: "Cálido"
        case .neutral: "Neutro"
        case .cool: "Frío"
        }
    }
}

public enum RemoteCameraCommand: Codable, Sendable, Equatable {
    case setMuted(Bool)
    case setZoom(Double)
    case setExposureBias(Float)
    case setWhiteBalance(String)
    case setLens(String)
    case applySavedSettings(RemoteCameraSettings)
    case setSwitcherAssignment(CameraSwitcherAssignment)
    case reconnectStream
}

/// Automatic per-camera settings persistence (keyed by device UUID).
public actor CameraSettingsStore {
    public static let shared = CameraSettingsStore()

    private let storageKey = "com.easystream.remoteCameraSettings"
    private var cache: [UUID: RemoteCameraSettings] = [:]

    public init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([UUID: RemoteCameraSettings].self, from: data) {
            cache = decoded
        }
    }

    public func settings(for sourceID: CameraSourceID) -> RemoteCameraSettings {
        cache[sourceID.rawValue] ?? RemoteCameraSettings()
    }

    public func save(_ settings: RemoteCameraSettings, for sourceID: CameraSourceID) {
        cache[sourceID.rawValue] = settings
        persist()
    }

    public func update(for sourceID: CameraSourceID, _ mutate: (inout RemoteCameraSettings) -> Void) -> RemoteCameraSettings {
        var current = settings(for: sourceID)
        mutate(&current)
        save(current, for: sourceID)
        return current
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(cache) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

public enum SwitchTransitionKind: String, Sendable, Codable, CaseIterable, Identifiable {
    case cut
    case dissolve
    case fade

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .cut: "Corte"
        case .dissolve: "Disolución"
        case .fade: "Fundido"
        }
    }
}

public struct SwitchTransition: Sendable, Equatable, Codable {
    public var kind: SwitchTransitionKind
    public var duration: TimeInterval

    public init(kind: SwitchTransitionKind, duration: TimeInterval = 0.5) {
        self.kind = kind
        self.duration = kind == .cut ? 0 : duration
    }

    public static let cut = SwitchTransition(kind: .cut, duration: 0)
    public static let dissolve = SwitchTransition(kind: .dissolve, duration: 0.5)
    public static let fade = SwitchTransition(kind: .fade, duration: 0.5)
}

public struct SwitcherSnapshot: Sendable, Equatable {
    public var previewSourceID: CameraSourceID?
    public var programSourceID: CameraSourceID?
    public var programAudioSourceID: CameraSourceID?
    public var fallbackSourceID: CameraSourceID?
    public var preferredTransition: SwitchTransition

    public init(
        previewSourceID: CameraSourceID? = nil,
        programSourceID: CameraSourceID? = nil,
        programAudioSourceID: CameraSourceID? = nil,
        fallbackSourceID: CameraSourceID? = nil,
        preferredTransition: SwitchTransition = .cut
    ) {
        self.previewSourceID = previewSourceID
        self.programSourceID = programSourceID
        self.programAudioSourceID = programAudioSourceID
        self.fallbackSourceID = fallbackSourceID
        self.preferredTransition = preferredTransition
    }
}
