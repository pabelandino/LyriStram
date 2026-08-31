import Foundation
import Network
import EasyStreamCore
import EasyStreamDiscovery
import EasyStreamTransport
import EasyStreamCameraCapture
import WebRTC

@MainActor
@Observable
final class CameraSessionViewModel {
    private(set) var devices: [DiscoveredDevice] = []
    private(set) var isRunning = false
    private(set) var statusMessage = "Iniciando…"
    private(set) var needsLocalNetworkPermission = false
    private(set) var streamState: StreamConnectionState = .idle
    private(set) var localPreviewSession: AVCaptureSession?
    private(set) var permissionStatus: CameraPermissionStatus = .notDetermined
    private(set) var imagingState = CameraImagingState()
    private(set) var lastError: String?
    private(set) var switcherAssignment: CameraSwitcherAssignment = .idle

    private let deviceID = DeviceIdentity.current().deviceID
    private let settingsStore = CameraSettingsStore.shared

    private var isApplyingRemoteSettings = false

    var isMuted = false {
        didSet {
            guard !isApplyingRemoteSettings else { return }
            applyLocalChange(mute: isMuted)
        }
    }

    private let discovery = DiscoveryService()
    private let capture = CameraCaptureService()
    private let streamClient = CameraStreamClient()
    private var signalingChannel: SignalingChannel?

    private var discoveryTask: Task<Void, Never>?
    private var streamTask: Task<Void, Never>?
    private var connectedDirectorID: UUID?

    func start(identity: DeviceIdentity) {
        guard !isRunning else { return }

        capture.onImagingStateChanged = { [weak self] state in
            Task { @MainActor in
                self?.imagingState = state
                self?.reportSettingsState()
            }
        }

        discoveryTask = Task {
            let stream = await discovery.events()
            for await event in stream {
                guard !Task.isCancelled else { break }
                handleDiscoveryEvent(event)
            }
        }

        Task {
            permissionStatus = await capture.requestPermission()
            guard permissionStatus == .authorized else {
                statusMessage = "Permiso de cámara requerido"
                return
            }

            let saved = await settingsStore.settings(for: CameraSourceID(deviceID))
            isApplyingRemoteSettings = true
            isMuted = saved.isMuted
            isApplyingRemoteSettings = false

            do {
                try await discovery.start(role: .camera, identity: identity)
                isRunning = true
                statusMessage = "Buscando Director…"
                await refreshDevices()
                try capture.start()
                RemoteCameraCommandExecutor.applySavedSettings(saved, capture: capture)
                imagingState = capture.imagingState
                localPreviewSession = capture.makePreviewSession()
                wireCaptureToWebRTC()
                observeStreamClient()
            } catch {
                lastError = error.localizedDescription
                statusMessage = "Error al iniciar"
            }
        }
    }

    func stop() {
        discoveryTask?.cancel()
        streamTask?.cancel()
        connectedDirectorID = nil
        signalingChannel = nil
        capture.stop()
        Task {
            await streamClient.stop()
            await discovery.stop()
        }
        isRunning = false
        streamState = .idle
        switcherAssignment = .idle
        localPreviewSession = nil
        devices = []
    }

    func selectLens(_ kind: CameraLensKind) {
        do {
            try capture.switchLens(to: kind)
            imagingState = capture.imagingState
            reportSettingsState()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func setZoom(_ factor: Double) {
        do {
            try capture.setZoom(factor: factor)
            imagingState = capture.imagingState
            reportSettingsState()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func setExposureBias(_ bias: Float) {
        do {
            try capture.setExposureBias(bias)
            imagingState = capture.imagingState
            reportSettingsState()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func setWhiteBalance(_ mode: WhiteBalanceModeOption) {
        do {
            try capture.setWhiteBalance(mode)
            imagingState = capture.imagingState
            reportSettingsState()
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func applyLocalChange(mute: Bool? = nil) {
        Task {
            if let mute {
                await streamClient.setAudioMuted(mute)
            }
            await persistAndReport()
        }
    }

    private func handleRemoteCommand(_ command: RemoteCameraCommand) {
        Task {
            isApplyingRemoteSettings = true
            switch command {
            case .setMuted(let muted):
                isMuted = muted
                await streamClient.setAudioMuted(muted)
            case .setSwitcherAssignment(let assignment):
                switcherAssignment = assignment
            default:
                RemoteCameraCommandExecutor.apply(command, capture: capture)
                imagingState = capture.imagingState
            }
            isApplyingRemoteSettings = false
            await persistAndReport()
        }
    }

    private func persistAndReport() async {
        let snapshot = RemoteCameraCommandExecutor.snapshot(from: capture, isMuted: await streamClient.isAudioMuted)
        await settingsStore.save(snapshot, for: CameraSourceID(deviceID))
        await reportSettingsState(snapshot)
    }

    private func reportSettingsState(_ snapshot: RemoteCameraSettings? = nil) {
        Task {
            let settings: RemoteCameraSettings
            if let snapshot {
                settings = snapshot
            } else {
                settings = RemoteCameraCommandExecutor.snapshot(
                    from: capture,
                    isMuted: await streamClient.isAudioMuted
                )
            }
            await settingsStore.save(settings, for: CameraSourceID(deviceID))
            if let signalingChannel {
                try? await signalingChannel.send(.settingsState(deviceID: deviceID, settings: settings))
            }
        }
    }

    private func handleDiscoveryEvent(_ event: DiscoveryEvent) {
        switch event {
        case .deviceAppeared(let device), .deviceUpdated(let device):
            Task {
                await refreshDevices()
                if device.role == .director {
                    await connectIfNeeded(to: device, identity: DeviceIdentity.current())
                }
            }
        case .deviceRemoved:
            Task { await refreshDevices() }
        case .browsingFailed(let message), .advertisingFailed(let message):
            lastError = message
            statusMessage = message
        case .localNetworkPermissionRequired:
            needsLocalNetworkPermission = true
            statusMessage = "Permiso de red local requerido"
        }
    }

    private func refreshDevices() async {
        devices = await discovery.discoveredDevices
    }

    private func connectIfNeeded(to director: DiscoveredDevice, identity: DeviceIdentity) async {
        guard connectedDirectorID == nil else { return }
        connectedDirectorID = director.id
        streamState = .connecting
        statusMessage = "Conectando a \(director.displayName)…"

        let connection = NWConnection(to: director.endpoint, using: .tcp)
        let channel = SignalingChannel(connection: connection)
        signalingChannel = channel
        await streamClient.attachSignaling(channel)
        await streamClient.prepareMediaTracks()
        await streamClient.setAudioMuted(isMuted)

        streamTask = Task {
            for await event in await channel.events() {
                guard !Task.isCancelled else { break }
                switch event {
                case .connected:
                    streamState = .signaling
                    statusMessage = "Negociando WebRTC…"
                    try? await channel.send(.hello(
                        deviceID: identity.deviceID,
                        displayName: identity.displayName,
                        role: AppRole.camera.rawValue
                    ))
                    try? await streamClient.startOffer()
                    await reportSettingsState()
                case .message(let message):
                    switch message {
                    case .control(let command):
                        handleRemoteCommand(command)
                    default:
                        try? await streamClient.handleSignalingMessage(message)
                    }
                case .disconnected:
                    streamState = .disconnected
                    statusMessage = "Desconectado del Director"
                    connectedDirectorID = nil
                    signalingChannel = nil
                case .failed(let error):
                    lastError = error
                    streamState = .failed
                    statusMessage = "Error de conexión"
                    connectedDirectorID = nil
                    signalingChannel = nil
                }
            }
        }
    }

    private func wireCaptureToWebRTC() {
        capture.onVideoFrame = { [streamClient] pixelBuffer, time in
            let timestampNs = Int64(CMTimeGetSeconds(time) * 1_000_000_000)
            Task {
                await streamClient.publish(pixelBuffer: pixelBuffer, timestampNs: timestampNs)
            }
        }
    }

    private func observeStreamClient() {
        Task {
            for await event in await streamClient.events() {
                switch event {
                case .connectionState(let state):
                    streamState = state
                    if state == .connected {
                        statusMessage = "Transmitiendo al Director"
                    }
                case .failed(let error):
                    lastError = error
                    streamState = .failed
                case .localVideoTrackReady:
                    break
                }
            }
        }
    }
}

import CoreMedia
