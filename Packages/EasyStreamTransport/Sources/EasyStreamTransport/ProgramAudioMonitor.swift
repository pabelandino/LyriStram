import AVFoundation
import Foundation
import Observation
import EasyStreamCore

/// Program-audio trim, local interface, and monitor output for the director.
@MainActor
@Observable
public final class ProgramAudioMonitor {
    public static let shared = ProgramAudioMonitor()

    public var latencyMode: ProgramAudioLatencyMode {
        didSet { persist(); pushRoute() }
    }

    public var manualLatencyMs: Double {
        didSet { persist(); pushRoute() }
    }

    public var outputChoice: ProgramAudioOutputChoice {
        didSet {
            persist()
            applyOutput()
        }
    }

    public private(set) var pictureLatencyMs: Double = 0
    public private(set) var outputRouteName = "Salida del sistema"
    public private(set) var localInputs: [ProgramAudioLocalInput] = []
    public var level: Float = 0

    public var feedsLiveVideo = false
    public var usesLocalInput = false

    private let modeKey = "com.easystream.audioLatencyMode"
    private let manualKey = "com.easystream.audioManualLatencyMs"
    private let outputKey = "com.easystream.audioOutputChoice"

    private init() {
        let defaults = UserDefaults.standard
        latencyMode = ProgramAudioLatencyMode(rawValue: defaults.string(forKey: modeKey) ?? "") ?? .picture
        manualLatencyMs = min(800, max(0, defaults.double(forKey: manualKey)))
        outputChoice = ProgramAudioOutputChoice(rawValue: defaults.string(forKey: outputKey) ?? "") ?? .system
        refreshDevices()
        applyOutput()
        pushRoute()
        observeRouteChanges()
    }

    public var appliedLatencyMs: Double {
        switch latencyMode {
        case .manual:
            return manualLatencyMs
        case .picture:
            return usesLocalInput ? pictureLatencyMs : 0
        }
    }

    public func notePictureLatency(_ milliseconds: Double?) {
        let value = min(800, max(0, milliseconds ?? 0))
        guard abs(value - pictureLatencyMs) > 8 else { return }
        pictureLatencyMs = value
        pushRoute()
    }

    public func setFeedsLiveVideo(_ feeds: Bool) {
        feedsLiveVideo = feeds
        if feeds { usesLocalInput = false }
        pushRoute()
    }

    public func setUsesLocalInput(_ uses: Bool, uid: String?) {
        usesLocalInput = uses
        if uses { feedsLiveVideo = false }
#if os(iOS)
        ProgramAudioDeviceRegistry.sharedDevice.selectLocalInput(uid: uid)
        ProgramAudioDeviceRegistry.sharedDevice.setLocalCaptureEnabled(uses)
#endif
        pushRoute()
    }

    public func refreshDevices() {
#if os(iOS)
        let session = AVAudioSession.sharedInstance()
        localInputs = (session.availableInputs ?? []).map {
            ProgramAudioLocalInput(id: $0.uid, name: $0.portName)
        }
        outputRouteName = session.currentRoute.outputs.first?.portName ?? "Salida del sistema"
#else
        localInputs = []
        outputRouteName = "Salida del sistema"
#endif
    }

    public func refreshLevel() {
        level = ProgramAudioLevelBus.current()
    }

    private func pushRoute() {
        let delay = feedsLiveVideo ? 0 : appliedLatencyMs
        ProgramAudioRouteFlags.shared.set(
            delayMs: delay,
            localCapture: usesLocalInput && !feedsLiveVideo,
            feedLiveVideo: feedsLiveVideo
        )
    }

    private func applyOutput() {
#if os(iOS)
        ProgramAudioDeviceRegistry.sharedDevice.apply(output: outputChoice)
        refreshDevices()
#endif
    }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(latencyMode.rawValue, forKey: modeKey)
        defaults.set(manualLatencyMs, forKey: manualKey)
        defaults.set(outputChoice.rawValue, forKey: outputKey)
    }

    private func observeRouteChanges() {
#if os(iOS)
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refreshDevices()
            }
        }
#endif
    }
}
