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
    private(set) var isReconnecting = false
    private(set) var selectedDirectorID: UUID?

    var availableDirectors: [DiscoveredDevice] {
        devices.filter { $0.role == .director && $0.serviceType == .director }
    }

    /// True once the operator explicitly picks a Director (vs. auto-selected when only one exists).
    private var userChoseDirector = false
    private var directorConnectionTask: Task<Void, Never>?
    private var connectionGeneration: UInt = 0
    private var lastAppliedTransportAssignment: CameraSwitcherAssignment?
    private var lastAppliedWebRTCStreamSpec: BroadcastStreamSpec?
    private var lastAppliedCaptureStreamSpec: BroadcastStreamSpec?
    var canReconnect: Bool {
        isRunning && !isReconnecting && streamState != .connecting && streamState != .signaling
    }

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
    private var signalingHealthTask: Task<Void, Never>?
    private(set) var connectedDirectorID: UUID?
    private var pendingDirectorID: UUID?

    func start(identity: DeviceIdentity) {
        guard !isRunning else { return }

        capture.onImagingStateChanged = { [weak self] state in
            Task { @MainActor in
                self?.imagingState = state
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
                capture.setStreamingDeliveryEnabled(false)
                capture.applyCaptureLoadTier(.idle, streamSpec: CameraTransportProfile.standby.streamSpec)
                RemoteCameraCommandExecutor.applySavedSettings(saved, capture: capture)
                imagingState = capture.imagingState
                localPreviewSession = capture.makePreviewSession()
        wireCaptureToWebRTC()
        observeStreamClient()
        startSignalingHealthWatch()
            } catch {
                lastError = error.localizedDescription
                statusMessage = "Error al iniciar"
            }
        }
    }

    func retryLocalNetworkAccess(identity: DeviceIdentity) {
        needsLocalNetworkPermission = false
        Task {
            do {
                try await discovery.start(role: .camera, identity: identity)
                isRunning = true
                statusMessage = "Buscando Director…"
                await refreshDevices()
            } catch {
                lastError = error.localizedDescription
                statusMessage = "Error al reconectar"
            }
        }
    }

    func stop() {
        discoveryTask?.cancel()
        directorConnectionTask?.cancel()
        directorConnectionTask = nil
        streamTask?.cancel()
        streamTask = nil
        signalingHealthTask?.cancel()
        signalingHealthTask = nil
        connectedDirectorID = nil
        pendingDirectorID = nil
        selectedDirectorID = nil
        signalingChannel = nil
        capture.setStreamingDeliveryEnabled(false)
        capture.stop()
        Task {
            await streamClient.stop()
            await discovery.stop()
        }
        isRunning = false
        isReconnecting = false
        userChoseDirector = false
        selectedDirectorID = nil
        streamState = .idle
        switcherAssignment = .idle
        localPreviewSession = nil
        devices = []
    }

    /// Connects the camera stream to a chosen Director (disconnects from the current one if needed).
    func selectDirector(_ director: DiscoveredDevice) {
        guard director.role == .director, director.serviceType == .director else { return }
        selectedDirectorID = director.id
        pendingDirectorID = director.id
        userChoseDirector = true
        streamState = .connecting
        statusMessage = "Conectando a \(director.displayName)…"
        scheduleDirectorConnection(force: true)
    }

    /// Reconnects to the Director without leaving camera mode.
    func reconnect() {
        guard isRunning, !isReconnecting else { return }
        Task {
            isReconnecting = true
            defer { isReconnecting = false }
            statusMessage = "Reconectando…"
            await disconnectStreamSession()
            streamState = .idle
            await refreshDevices()
            if preferredDirector() != nil {
                scheduleDirectorConnection(force: true)
            } else {
                statusMessage = availableDirectors.count > 1
                    ? "Elige un Director para transmitir"
                    : "Buscando Director…"
            }
        }
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
                await applyTransportProfile(for: assignment)
            case .setDirectorMonitorQuality(let quality):
                CameraTransportProfile.directorQuality = quality
                await applyTransportProfile(for: switcherAssignment)
            case .reconnectStream:
                await reconnectStreamToDirector()
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
                    await reconcileDirectorConnection()
                }
            }
        case .deviceRemoved(let deviceID):
            Task {
                await refreshDevices()
                if selectedDirectorID == deviceID {
                    selectedDirectorID = nil
                    await disconnectStreamSession()
                    streamState = .idle
                    statusMessage = availableDirectors.count > 1
                        ? "Elige un Director para transmitir"
                        : "Buscando Director…"
                }
            }
        case .browsingFailed(let message), .advertisingFailed(let message):
            lastError = message
            statusMessage = message
        case .localNetworkPermissionRequired:
            needsLocalNetworkPermission = true
            statusMessage = "Permiso de red local requerido"
        }
    }

    private func preferredDirector() -> DiscoveredDevice? {
        if let selectedDirectorID,
           let selected = availableDirectors.first(where: { $0.id == selectedDirectorID }) {
            return selected
        }
        if availableDirectors.count == 1 {
            return availableDirectors.first
        }
        return nil
    }

    private func reconcileDirectorConnection() async {
        let directors = availableDirectors
        guard !directors.isEmpty else {
            statusMessage = "Buscando Director…"
            return
        }

        if directors.count == 1 {
            if selectedDirectorID == nil {
                selectedDirectorID = directors[0].id
            }
            scheduleDirectorConnection(force: false)
            return
        }

        guard userChoseDirector, selectedDirectorID != nil else {
            if streamState == .connecting || streamState == .signaling {
                await disconnectStreamSession()
                streamState = .idle
            }
            selectedDirectorID = nil
            pendingDirectorID = nil
            statusMessage = "Elige un Director para transmitir"
            return
        }

        if isConnectionInProgress(for: selectedDirectorID) {
            return
        }

        scheduleDirectorConnection(force: false)
    }

    private func isConnectionInProgress(for directorID: UUID?) -> Bool {
        guard let directorID else { return false }
        let isTarget = pendingDirectorID == directorID || connectedDirectorID == directorID
        guard isTarget else { return false }
        switch streamState {
        case .connecting, .signaling, .connected:
            return true
        default:
            return false
        }
    }

    private func makeSignalingParameters(for director: DiscoveredDevice) -> NWParameters {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        parameters.multipathServiceType = .disabled
        // Infrastructure Wi‑Fi is more reliable than AWDL when several cameras connect to one director.
        parameters.includePeerToPeer = false
        return parameters
    }

    private func scheduleDirectorConnection(force: Bool) {
        directorConnectionTask?.cancel()
        directorConnectionTask = Task {
            guard !Task.isCancelled else { return }
            guard let director = preferredDirector() else { return }
            await performDirectorConnection(to: director, force: force)
        }
    }

    private func performDirectorConnection(to director: DiscoveredDevice, force: Bool) async {
        guard let freshDirector = availableDirectors.first(where: { $0.id == director.id }),
              freshDirector.serviceType == .director else {
            statusMessage = "Director no disponible"
            return
        }

        if !force {
            let isSameDirector = connectedDirectorID == freshDirector.id || pendingDirectorID == freshDirector.id
            if isSameDirector {
                switch streamState {
                case .connected, .signaling, .connecting:
                    return
                default:
                    break
                }
            } else if streamState == .connected {
                return
            }
        }

        await disconnectStreamSession()
        streamState = .idle

        connectionGeneration &+= 1
        let generation = connectionGeneration

        pendingDirectorID = freshDirector.id
        selectedDirectorID = freshDirector.id
        streamState = .connecting
        statusMessage = "Conectando a \(freshDirector.displayName)…"

        let identity = DeviceIdentity.current()
        let parameters = makeSignalingParameters(for: freshDirector)
        let connection = NWConnection(to: freshDirector.endpoint, using: parameters)
        let channel = SignalingChannel(connection: connection)
        signalingChannel = channel

        let eventStream = await channel.events()
        await streamClient.attachSignaling(channel)
        await streamClient.prepareMediaTracks()
        await streamClient.setAudioMuted(isMuted)

        streamTask?.cancel()
        streamTask = Task {
            for await event in eventStream {
                guard !Task.isCancelled, generation == connectionGeneration else { break }
                switch event {
                case .connected:
                    guard generation == connectionGeneration else { break }
                    connectedDirectorID = freshDirector.id
                    pendingDirectorID = nil
                    streamState = .signaling
                    statusMessage = "Negociando WebRTC…"
                    do {
                        try await channel.send(.hello(
                            deviceID: identity.deviceID,
                            displayName: identity.displayName,
                            role: AppRole.camera.rawValue
                        ))
                        try await streamClient.startOffer()
                        await reportSettingsState()
                        Task {
                            try? await Task.sleep(for: .seconds(25))
                            guard generation == connectionGeneration else { return }
                            if streamState == .signaling {
                                await reconnectStreamToDirector()
                            }
                        }
                    } catch {
                        guard generation == connectionGeneration else { break }
                        capture.setStreamingDeliveryEnabled(false)
                        lastError = error.localizedDescription
                        streamState = .failed
                        statusMessage = "Error al negociar con \(freshDirector.displayName)"
                        connectedDirectorID = nil
                        pendingDirectorID = nil
                        await channel.stop()
                        signalingChannel = nil
                    }
                case .message(let message):
                    guard generation == connectionGeneration else { break }
                    switch message {
                    case .control(let command):
                        handleRemoteCommand(command)
                    default:
                        try? await streamClient.handleSignalingMessage(message)
                    }
                case .disconnected:
                    guard generation == connectionGeneration else { break }
                    capture.setStreamingDeliveryEnabled(false)
                    streamState = .disconnected
                    statusMessage = "Desconectado del Director"
                    connectedDirectorID = nil
                    pendingDirectorID = nil
                    signalingChannel = nil
                case .failed(let error):
                    guard generation == connectionGeneration else { break }
                    capture.setStreamingDeliveryEnabled(false)
                    lastError = error
                    streamState = .failed
                    statusMessage = "Error de conexión"
                    connectedDirectorID = nil
                    pendingDirectorID = nil
                    signalingChannel = nil
                }
            }
        }
    }

    private func startSignalingHealthWatch() {
        signalingHealthTask?.cancel()
        signalingHealthTask = Task {
            while isRunning && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(15))
                guard !Task.isCancelled else { break }
                if streamState == .connected, signalingChannel == nil {
                    reconnect()
                }
            }
        }
    }

    private func refreshDevices() async {
        devices = await discovery.discoveredDevices
    }

    private func disconnectStreamSession() async {
        connectionGeneration &+= 1
        directorConnectionTask?.cancel()
        directorConnectionTask = nil
        streamTask?.cancel()
        streamTask = nil
        capture.setStreamingDeliveryEnabled(false)
        await streamClient.resetPeerConnection()
        if let channel = signalingChannel {
            await channel.stop()
        }
        signalingChannel = nil
        connectedDirectorID = nil
        pendingDirectorID = nil
        lastAppliedTransportAssignment = nil
        lastAppliedWebRTCStreamSpec = nil
        lastAppliedCaptureStreamSpec = nil
    }

    private func reconnectStreamToDirector() async {
        guard signalingChannel != nil else {
            reconnect()
            return
        }
        isReconnecting = true
        defer { isReconnecting = false }
        capture.setStreamingDeliveryEnabled(false)
        await streamClient.resetPeerConnection()
        streamState = .signaling
        statusMessage = "Reconectando con el Director…"
        do {
            try await streamClient.startOffer()
            await reportSettingsState()
        } catch {
            lastError = error.localizedDescription
            streamState = .failed
            statusMessage = "Error al reconectar"
        }
    }

    private func wireCaptureToWebRTC() {
        let publisher = streamClient.videoFramePublisher
        capture.onVideoFrame = { pixelBuffer, time in
            let timestampNs = CMTimeConvertScale(
                time,
                timescale: 1_000_000_000,
                method: .roundTowardZero
            ).value
            publisher.publish(pixelBuffer: pixelBuffer, timestampNs: timestampNs)
        }
    }

    private func applyTransportProfile(for assignment: CameraSwitcherAssignment) async {
        let quality = CameraTransportProfile.directorQuality
        let webRTCProfile = CameraTransportProfile.webRTCProfile(for: assignment)
        let pauseIdle = quality.pauseIdleCameraStreams

        // Keep sensor preset stable for every active role; WebRTC scales preview vs program on the wire.
        let captureStreamSpec = assignment.isActive
            ? quality.progPreset.streamSpec
            : CameraTransportProfile.standby.streamSpec
        let captureTier: CameraCaptureLoadTier = assignment.isActive ? .program : .idle

        if assignment == lastAppliedTransportAssignment,
           webRTCProfile.streamSpec == lastAppliedWebRTCStreamSpec,
           captureStreamSpec == lastAppliedCaptureStreamSpec {
            return
        }

        lastAppliedTransportAssignment = assignment
        lastAppliedWebRTCStreamSpec = webRTCProfile.streamSpec
        lastAppliedCaptureStreamSpec = captureStreamSpec

        ProgramBusTrace.event(
            "camera transport apply assignment=\(assignment.rawValue) webrtc=\(webRTCProfile.width)x\(webRTCProfile.height)@\(webRTCProfile.frameRate) capture=\(captureStreamSpec.width)x\(captureStreamSpec.height)@\(captureStreamSpec.frameRate) tier=\(captureTierLabel(for: assignment))"
        )

        if assignment.isActive {
            capture.setStreamingDeliveryEnabled(true)
            await streamClient.updateTransportProfile(webRTCProfile)
            capture.applyCaptureLoadTier(captureTier, streamSpec: captureStreamSpec)
        } else if pauseIdle {
            capture.setStreamingDeliveryEnabled(false)
            capture.applyCaptureLoadTier(.idle, streamSpec: CameraTransportProfile.standby.streamSpec)
        } else {
            capture.setStreamingDeliveryEnabled(true)
            capture.applyCaptureLoadTier(.idle, streamSpec: CameraTransportProfile.standby.streamSpec)
            await streamClient.updateTransportProfile(.standby)
        }
    }

    private func captureTierLabel(for assignment: CameraSwitcherAssignment) -> String {
        switch assignment {
        case .idle: "idle"
        case .preview: "preview"
        case .program, .previewAndProgram: "program"
        }
    }

    private func observeStreamClient() {
        Task {
            for await event in await streamClient.events() {
                switch event {
                case .connectionState(let state):
                    streamState = state
                    switch state {
                    case .connected:
                        // Wait for director assignment/quality before choosing idle vs active stream.
                        try? await Task.sleep(for: .milliseconds(250))
                        await applyTransportProfile(for: switcherAssignment)
                        statusMessage = switcherAssignment.isActive
                            ? "Transmitiendo al Director"
                            : "Conectada · en espera (bajo consumo)"
                    case .disconnected, .failed, .idle:
                        capture.setStreamingDeliveryEnabled(false)
                    default:
                        break
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
