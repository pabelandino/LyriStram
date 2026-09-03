import Foundation
import Observation
import EasyStreamCore
import EasyStreamDiscovery
import EasyStreamSwitcher
import EasyStreamTransport
import EasyStreamVideoPipeline
import EasyStreamAudioPipeline
import EasyStreamStreaming
import EasyStreamFacebook
import EasyStreamUIComponents
import WebRTC

struct ConnectedCameraSource: Identifiable, Equatable {
    let id: CameraSourceID
    var displayName: String
    var videoTrack: RTCVideoTrack?
    var audioTrack: RTCAudioTrack?
    var connectionState: StreamConnectionState
    var remoteSettings: RemoteCameraSettings

    static func == (lhs: ConnectedCameraSource, rhs: ConnectedCameraSource) -> Bool {
        lhs.id == rhs.id
            && lhs.displayName == rhs.displayName
            && lhs.connectionState == rhs.connectionState
            && lhs.remoteSettings == rhs.remoteSettings
    }
}

@MainActor
@Observable
final class DirectorSessionViewModel {
    private(set) var devices: [DiscoveredDevice] = []
    private(set) var sources: [ConnectedCameraSource] = []
    private(set) var isRunning = false
    private(set) var statusMessage = "Iniciando…"
    private(set) var needsLocalNetworkPermission = false
    private(set) var previewSourceID: CameraSourceID?
    private(set) var programSourceID: CameraSourceID?
    private(set) var programAudioSourceID: CameraSourceID?
    private(set) var lastError: String?
    private(set) var encoderStats = VideoEncoderStats()
    private(set) var audioEncoderStats = AudioEncoderStats()
    private(set) var publisherStats = StreamPublisherStats()
    private(set) var isFacebookLoading = false
    private(set) var facebookStatusMessage: String?

    var facebookSession = FacebookSessionStore.load()
    var facebookPages: [FacebookPage] = []

    var streamDestination: StreamDestination = StreamDestinationStore.load() {
        didSet { StreamDestinationStore.save(streamDestination) }
    }

    var monitorQuality: DirectorMonitorQualitySettings = DirectorMonitorQualityPreferencesStore.load() {
        didSet {
            guard monitorQuality != oldValue else { return }
            DirectorMonitorQualityPreferencesStore.save(monitorQuality)
            CameraTransportProfile.directorQuality = monitorQuality
            broadcastMonitorQuality()
            broadcastSwitcherAssignments()
            syncProgramEncoder()
        }
    }

    var isPublishing: Bool {
        publisherStats.state == .publishing || publisherStats.state == .connecting
    }

    var isFacebookConfigured: Bool {
        FacebookConfiguration.isConfigured
    }

    var selectedFacebookPageID: String? {
        facebookSession.selectedPageID
    }

    var selectedTransition: SwitchTransition = TransitionPreferencesStore.load() {
        didSet { TransitionPreferencesStore.save(selectedTransition) }
    }

    var inspectorSourceID: CameraSourceID?
    var outgoingProgramSourceID: CameraSourceID?
    var transitionProgress: Double = 1
    var isTransitioning = false
    /// Live count of attached WebRTC Metal sinks — useful for CPU diagnostics in director mode.
    var videoRendererSinkSnapshot: VideoRendererSinkSnapshot {
        VideoRendererSinkRegistry.snapshot()
    }
    /// Program bus frame counters — confirms Metal compositor is receiving frames.
    var programFrameBusSnapshot: [ProgramFrameTrackTelemetry] {
        ProgramFrameTelemetryRegistry.live.snapshot()
    }
    /// Preview track pinned for the full animated take — survives `take()` assigning preview to program.
    private(set) var transitionIncomingVideoTrack: RTCVideoTrack?
    /// Take target pinned by source ID through switcher handoff (cut + animated end).
    private(set) var takeHandoffSourceID: CameraSourceID?

    private let settingsStore = CameraSettingsStore.shared
    private let discovery = DiscoveryService()
    private let streamReceiver = DirectorStreamReceiver()
    private let switcher = SwitcherEngine()
    private let programEncoder = ProgramVideoEncoderPipeline()
    private let programAudioEncoder = ProgramAudioEncoderPipeline()
    private let broadcastPublisher = BroadcastStreamPublisher()
    private let facebookLive = FacebookLiveService()
    private var discoveryTask: Task<Void, Never>?
    private var streamTask: Task<Void, Never>?
    private var encoderTask: Task<Void, Never>?
    private var audioEncoderTask: Task<Void, Never>?
    private var publisherTask: Task<Void, Never>?
    private var lastEncoderStatsRefresh = Date.distantPast
    private var lastAudioStatsRefresh = Date.distantPast
    private let statsRefreshInterval: TimeInterval = 2.0
    /// H.264 program encoder runs only while RTMP/network publish is active — not during normal monitoring.
    private var isStreamEncodingEnabled = false

    var programVideoTrack: RTCVideoTrack? {
        track(for: programSourceID)
    }

    var outgoingProgramVideoTrack: RTCVideoTrack? {
        track(for: outgoingProgramSourceID)
    }

    var previewVideoTrack: RTCVideoTrack? {
        track(for: previewSourceID)
    }

    /// Preview track pre-decoded on the compositor incoming lane for glitch-free cuts.
    var warmedPreviewVideoTrack: RTCVideoTrack? {
        guard !isTransitioning else { return nil }
        guard let previewSourceID,
              previewSourceID != programSourceID else { return nil }
        return previewVideoTrack
    }

    /// Incoming lane wired into the compositor (handoff pin or preview warm — single entry point).
    /// Scales to N sources: only the selected preview is warmed; all others stay idle on the bus.
    var programBusIncomingTrack: RTCVideoTrack? {
        if isTransitioning {
            return transitionIncomingVideoTrack
        }
        if let takeHandoffSourceID {
            return track(for: takeHandoffSourceID)
        }
        guard monitorQuality.prefetchTakeTarget else { return nil }
        return warmedPreviewVideoTrack
    }

    /// On-air program bus only — never mirrors preview (preview warms on the incoming compositor lane).
    var programDisplayTrack: RTCVideoTrack? {
        if isTransitioning {
            return outgoingProgramVideoTrack ?? programVideoTrack
        }
        return programVideoTrack
    }

    var connectedSourceCount: Int {
        sources.filter { $0.connectionState == .connected && $0.videoTrack != nil }.count
    }

    func settings(for sourceID: CameraSourceID) -> RemoteCameraSettings {
        sources.first { $0.id == sourceID }?.remoteSettings ?? RemoteCameraSettings()
    }

    func inspectorSourceName(for sourceID: CameraSourceID) -> String {
        sources.first { $0.id == sourceID }?.displayName ?? "Cámara"
    }

    func start(identity: DeviceIdentity) {
        guard !isRunning else { return }

        discoveryTask = Task {
            let stream = await discovery.events()
            for await event in stream {
                guard !Task.isCancelled else { break }
                handleDiscoveryEvent(event)
            }
        }

        streamTask = Task {
            for await event in await streamReceiver.events() {
                handleStreamEvent(event)
            }
        }

        observeProgramEncoder()
        observeProgramAudioEncoder()
        observeBroadcastPublisher()
        restoreFacebookSession()

        CameraTransportProfile.directorQuality = monitorQuality

        Task {
            await discovery.setIncomingConnectionHandler { [streamReceiver] connection in
                Task { await streamReceiver.handleIncomingConnection(connection) }
            }

            do {
                try await discovery.start(role: .director, identity: identity)
                isRunning = true
                statusMessage = "Esperando cámaras…"
                await refreshDevices()
                await switcher.setPreferredTransition(selectedTransition)
                broadcastMonitorQuality()
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
                try await discovery.start(role: .director, identity: identity)
                isRunning = true
                statusMessage = "Esperando cámaras…"
                await refreshDevices()
            } catch {
                lastError = error.localizedDescription
                statusMessage = "Error al reconectar"
            }
        }
    }

    func stop() {
        discoveryTask?.cancel()
        streamTask?.cancel()
        encoderTask?.cancel()
        audioEncoderTask?.cancel()
        publisherTask?.cancel()
        sources = []
        previewSourceID = nil
        programSourceID = nil
        programAudioSourceID = nil
        outgoingProgramSourceID = nil
        transitionIncomingVideoTrack = nil
        takeHandoffSourceID = nil
        syncPreviewMonitor()
        encoderStats = VideoEncoderStats()
        audioEncoderStats = AudioEncoderStats()
        publisherStats = StreamPublisherStats()
        isStreamEncodingEnabled = false
        Task {
            await broadcastPublisher.stop()
            await programAudioEncoder.stop()
            await programEncoder.stop()
            await discovery.setIncomingConnectionHandler(nil)
            await streamReceiver.stop()
            await discovery.stop()
        }
        isRunning = false
    }

    func selectPreview(_ sourceID: CameraSourceID) {
        Task { await selectPreviewAndSync(sourceID) }
    }

    func selectPreviewAndSync(_ sourceID: CameraSourceID) async {
        guard takeHandoffSourceID == nil else { return }
        inspectorSourceID = sourceID
        guard previewSourceID != sourceID else {
            broadcastSwitcherAssignments()
            return
        }
        if let event = await switcher.setPreview(sourceID) {
            applySwitcherEvent(event)
        }
        broadcastSwitcherAssignments()
        // Give remote cameras time to ramp from standby → preview tier before take.
        try? await Task.sleep(for: .milliseconds(120))
    }

    func takeToProgram() {
        guard !isTransitioning else { return }
        guard takeHandoffSourceID == nil else { return }
        Task { await performTakeToProgram() }
    }

    func startPublishing() {
        guard !isPublishing else { return }
        isStreamEncodingEnabled = true
        StreamDestinationStore.save(streamDestination)
        Task {
            await broadcastPublisher.start(destination: streamDestination)
            syncProgramEncoder()
        }
    }

    func stopPublishing() {
        isStreamEncodingEnabled = false
        Task {
            await broadcastPublisher.stop()
            await endFacebookLiveIfNeeded()
            syncProgramEncoder()
        }
    }

    func signInWithFacebook() {
        Task {
            isFacebookLoading = true
            facebookStatusMessage = nil
            defer { isFacebookLoading = false }
            do {
                facebookSession = try await facebookLive.signIn()
                facebookStatusMessage = "Sesión iniciada. Autoriza acceso a Páginas para transmitir en vivo."
            } catch {
                lastError = error.localizedDescription
                facebookStatusMessage = error.localizedDescription
            }
        }
    }

    func authorizeFacebookPages() {
        Task {
            isFacebookLoading = true
            defer { isFacebookLoading = false }
            do {
                facebookSession = try await facebookLive.authorizePages(for: facebookSession)
                await refreshFacebookPages()
                if facebookPages.isEmpty {
                    facebookStatusMessage = FacebookAuthError.pagePermissionsNotConfigured.errorDescription
                } else {
                    facebookStatusMessage = "Páginas de Facebook conectadas"
                }
            } catch {
                lastError = error.localizedDescription
                facebookStatusMessage = error.localizedDescription
            }
        }
    }

    func signOutFromFacebook() {
        Task {
            await facebookLive.signOut()
            facebookSession = FacebookSession()
            facebookPages = []
            facebookStatusMessage = nil
        }
    }

    func selectFacebookPage(_ pageID: String) {
        facebookSession.selectedPageID = pageID
        FacebookSessionStore.save(facebookSession)
    }

    func prepareFacebookLive() {
        guard let pageID = facebookSession.selectedPageID,
              let page = facebookPages.first(where: { $0.id == pageID }) else { return }

        Task {
            isFacebookLoading = true
            defer { isFacebookLoading = false }
            do {
                let (liveVideo, destination) = try await facebookLive.prepareLiveBroadcast(
                    session: facebookSession,
                    page: page,
                    title: "EasyStream Live"
                )
                facebookSession = FacebookSessionStore.load()
                streamDestination = destination
                facebookStatusMessage = "Destino RTMPS listo · \(liveVideo.id)"
            } catch {
                lastError = error.localizedDescription
                facebookStatusMessage = error.localizedDescription
            }
        }
    }

    func cutToPreview() {
        takeToProgram()
    }

    private func performTakeToProgram() async {
        let transition = selectedTransition
        await switcher.setPreferredTransition(transition)

        guard let target = previewSourceID else { return }
        if let programSourceID, target == programSourceID { return }

        broadcastSwitcherAssignments()
        guard let incoming = await waitForVideoTrack(sourceID: target) else {
            lastError = "La cámara en preview aún no tiene señal de video."
            statusMessage = "Espera a que la cámara conecte antes de llevarla al aire."
            return
        }

        takeHandoffSourceID = target
        transitionIncomingVideoTrack = incoming

        if transition.kind == .cut || transition.duration <= 0 {
            outgoingProgramSourceID = nil
            transitionProgress = 1
            isTransitioning = false
            let events = await switcher.take(to: target, transition: transition)
            applySwitcherEvents(events)
            await completeTakeHandoff()
            return
        }

        outgoingProgramSourceID = programSourceID
        isTransitioning = true
        transitionProgress = 0
        await Task.yield()

#if os(iOS)
        let transitionFrameRate = 30
#else
        let transitionFrameRate = 60
#endif
        await ProgramTransitionDisplayLink.animate(
            duration: transition.duration,
            preferredFramesPerSecond: transitionFrameRate
        ) { [self] progress in
            transitionProgress = progress
        }

        transitionProgress = 1
        let events = await switcher.take(to: target, transition: transition)
        applySwitcherEvents(events)
        outgoingProgramSourceID = nil
        isTransitioning = false
        await completeTakeHandoff()
    }

    /// Lets compositor finish handoff while take target remains pinned by source ID.
    private func completeTakeHandoff() async {
        await Task.yield()
        takeHandoffSourceID = nil
        transitionIncomingVideoTrack = nil
    }

    private func waitForVideoTrack(sourceID: CameraSourceID, attempts: Int = 8) async -> RTCVideoTrack? {
        for attempt in 0..<attempts {
            if let track = track(for: sourceID) {
                return track
            }
            if attempt == 0 {
                broadcastSwitcherAssignments()
            }
            try? await Task.sleep(for: .milliseconds(100))
        }
        return track(for: sourceID)
    }

    func setProgramAudioSource(_ sourceID: CameraSourceID) {
        Task {
            if let event = await switcher.setProgramAudioSource(sourceID) {
                applySwitcherEvent(event)
            }
        }
    }

    func setMuted(_ muted: Bool, for sourceID: CameraSourceID) {
        persistAndSend(sourceID, command: .setMuted(muted)) { $0.isMuted = muted }
    }

    func setZoom(_ factor: Double, for sourceID: CameraSourceID) {
        persistAndSend(sourceID, command: .setZoom(factor)) { $0.zoomFactor = factor }
    }

    func setExposureBias(_ bias: Float, for sourceID: CameraSourceID) {
        persistAndSend(sourceID, command: .setExposureBias(bias)) { $0.exposureBias = bias }
    }

    func setWhiteBalance(_ mode: String, for sourceID: CameraSourceID) {
        persistAndSend(sourceID, command: .setWhiteBalance(mode)) { $0.whiteBalance = mode }
    }

    func setLens(_ lens: String, for sourceID: CameraSourceID) {
        persistAndSend(sourceID, command: .setLens(lens)) { $0.activeLens = lens }
    }

    func reconnectCamera(_ sourceID: CameraSourceID) {
        Task {
            markSourceReconnecting(sourceID)
            statusMessage = "Reconectando \(inspectorSourceName(for: sourceID))…"
            do {
                try await streamReceiver.prepareReconnect(for: sourceID)
            } catch {
                upsertSource(sourceID, connectionState: .disconnected)
                lastError = "No se pudo contactar la cámara. Usa Reconectar en el iPhone."
                statusMessage = "Reconexión fallida"
            }
        }
    }

    func connectionState(for sourceID: CameraSourceID) -> StreamConnectionState {
        sources.first { $0.id == sourceID }?.connectionState ?? .disconnected
    }

    private func markSourceReconnecting(_ sourceID: CameraSourceID) {
        guard let index = sources.firstIndex(where: { $0.id == sourceID }) else { return }
        sources[index].videoTrack = nil
        sources[index].connectionState = .connecting
        syncPreviewMonitor()
    }

    func source(at index: Int) -> CameraSourceID? {
        guard sources.indices.contains(index) else { return nil }
        return sources[index].id
    }

    private func persistAndSend(
        _ sourceID: CameraSourceID,
        command: RemoteCameraCommand,
        apply change: @escaping (inout RemoteCameraSettings) -> Void
    ) {
        Task {
            var updated = await settingsStore.settings(for: sourceID)
            change(&updated)
            await settingsStore.save(updated, for: sourceID)
            upsertSource(sourceID, remoteSettings: updated)
            try? await streamReceiver.sendControl(to: sourceID, command: command)
        }
    }

    private func handleDiscoveryEvent(_ event: DiscoveryEvent) {
        switch event {
        case .deviceAppeared, .deviceUpdated, .deviceRemoved:
            Task { await refreshDevices() }
        case .browsingFailed(let message), .advertisingFailed(let message):
            lastError = message
            statusMessage = message
        case .localNetworkPermissionRequired:
            needsLocalNetworkPermission = true
            statusMessage = "Permiso de red local requerido"
        }
    }

    private func handleStreamEvent(_ event: DirectorStreamReceiver.Event) {
        switch event {
        case .sourceConnected(let sourceID, let displayName):
            Task {
                let saved = await settingsStore.settings(for: sourceID)
                upsertSource(sourceID, displayName: displayName, connectionState: .connecting, remoteSettings: saved)
                if let switchEvent = await switcher.registerSource(sourceID) {
                    applySwitcherEvent(switchEvent)
                }
                await syncSwitcherState()
                if inspectorSourceID == nil { inspectorSourceID = sourceID }
                syncProgramAudioEncoder()
            }
            statusMessage = "\(displayName) conectada"

        case .sourceDisconnected(let sourceID):
            sources.removeAll { $0.id == sourceID }
            Task {
                let events = await switcher.unregisterSource(sourceID)
                for event in events { applySwitcherEvent(event) }
                await syncSwitcherState()
            }
            statusMessage = "Cámara desconectada"

        case .sourceVideoTrack(let sourceID, let track, let displayName):
            upsertSource(sourceID, displayName: displayName, videoTrack: track, connectionState: .connected)
            statusMessage = "\(connectedSourceCount) cámara(s) en vivo"
            if sourceID == programSourceID {
                syncProgramEncoder()
            }

        case .sourceAudioTrack(let sourceID, let track, let displayName):
            upsertSource(sourceID, displayName: displayName, audioTrack: track)
            updateAudioRouting()
            if sourceID == programAudioSourceID {
                syncProgramAudioEncoder()
            }

        case .sourceConnectionState(let sourceID, let state):
            upsertSource(sourceID, connectionState: state)

        case .sourceSettingsUpdated(let sourceID, let settings):
            Task {
                await settingsStore.save(settings, for: sourceID)
                upsertSource(sourceID, remoteSettings: settings)
            }

        case .failed(let error):
            lastError = error
            statusMessage = "Error de stream"
        }
    }

    private func upsertSource(
        _ sourceID: CameraSourceID,
        displayName: String? = nil,
        videoTrack: RTCVideoTrack? = nil,
        audioTrack: RTCAudioTrack? = nil,
        connectionState: StreamConnectionState? = nil,
        remoteSettings: RemoteCameraSettings? = nil
    ) {
        if let index = sources.firstIndex(where: { $0.id == sourceID }) {
            var source = sources[index]
            if let displayName { source.displayName = displayName }
            if let videoTrack {
                source.videoTrack = videoTrack
                if source.connectionState == .connecting || source.connectionState == .signaling {
                    source.connectionState = .connected
                }
            }
            if let audioTrack { source.audioTrack = audioTrack }
            if let connectionState { source.connectionState = connectionState }
            if let remoteSettings { source.remoteSettings = remoteSettings }
            sources[index] = source
        } else {
            sources.append(ConnectedCameraSource(
                id: sourceID,
                displayName: displayName ?? "Cámara",
                videoTrack: videoTrack,
                audioTrack: audioTrack,
                connectionState: connectionState ?? .connecting,
                remoteSettings: remoteSettings ?? RemoteCameraSettings()
            ))
        }
        sources.sort { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
        syncPreviewMonitor()
        broadcastSwitcherAssignments()
    }

    private func syncPreviewMonitor() {
        DirectorPreviewMonitorStore.shared.sync(
            sources: sources,
            previewSourceID: previewSourceID,
            programSourceID: programSourceID,
            programAudioSourceID: programAudioSourceID
        )
    }

    private func applySwitcherEvent(_ event: SwitcherEvent) {
        applySwitcherEvents([event])
    }

    private func applySwitcherEvents(_ events: [SwitcherEvent]) {
        for event in events {
            switch event {
            case .previewChanged(let id):
                previewSourceID = id
                if inspectorSourceID == nil { inspectorSourceID = id }
            case .programChanged(let id):
                programSourceID = id
                syncProgramEncoder()
            case .programAudioChanged(let id):
                programAudioSourceID = id
                updateAudioRouting()
                syncProgramAudioEncoder()
            case .fallbackChanged, .transitionChanged:
                break
            }
        }
        updateAudioRouting()
        syncPreviewMonitor()
        broadcastSwitcherAssignments()
    }

    private func broadcastSwitcherAssignments() {
        for source in sources {
            let assignment = switcherAssignment(for: source.id)
            Task {
                try? await streamReceiver.sendControl(
                    to: source.id,
                    command: .setSwitcherAssignment(assignment)
                )
            }
        }
    }

    private func broadcastMonitorQuality() {
        let quality = monitorQuality
        for source in sources {
            Task {
                try? await streamReceiver.sendControl(
                    to: source.id,
                    command: .setDirectorMonitorQuality(quality)
                )
            }
        }
    }

    private func switcherAssignment(for sourceID: CameraSourceID) -> CameraSwitcherAssignment {
        let isPreview = sourceID == previewSourceID
        let isProgram = sourceID == programSourceID
        switch (isPreview, isProgram) {
        case (true, true): return .previewAndProgram
        case (false, true): return .program
        case (true, false): return .preview
        case (false, false): return .idle
        }
    }

    private func syncSwitcherState() async {
        let state = await switcher.state
        previewSourceID = state.previewSourceID
        programSourceID = state.programSourceID
        programAudioSourceID = state.programAudioSourceID
        syncPreviewMonitor()
        broadcastSwitcherAssignments()
    }

    private func track(for sourceID: CameraSourceID?) -> RTCVideoTrack? {
        guard let sourceID else { return nil }
        return sources.first { $0.id == sourceID }?.videoTrack
    }

    private func refreshDevices() async {
        devices = await discovery.discoveredDevices
    }

    private func updateAudioRouting() {
        for source in sources {
            source.audioTrack?.isEnabled = source.id == programAudioSourceID
        }
    }

    private func observeProgramEncoder() {
        encoderTask?.cancel()
        encoderTask = Task {
            for await event in await programEncoder.events() {
                guard !Task.isCancelled else { break }
                switch event {
                case .started:
                    await refreshEncoderStatsIfNeeded(force: true)
                case .sample(let sample):
                    await broadcastPublisher.sendVideo(sample)
                    await refreshEncoderStatsIfNeeded(force: false)
                case .stopped:
                    encoderStats = VideoEncoderStats()
                    lastEncoderStatsRefresh = .distantPast
                case .failed(let message):
                    lastError = message
                }
            }
        }
    }

    private func refreshEncoderStatsIfNeeded(force: Bool) async {
        let now = Date()
        guard force || now.timeIntervalSince(lastEncoderStatsRefresh) >= statsRefreshInterval else { return }
        lastEncoderStatsRefresh = now
        encoderStats = await programEncoder.stats()
    }

    private func syncProgramEncoder() {
        Task {
            guard isStreamEncodingEnabled, programVideoTrack != nil else {
                await programEncoder.stop()
                encoderStats = VideoEncoderStats()
                lastEncoderStatsRefresh = .distantPast
                return
            }
            await programEncoder.start(
                programTrack: programVideoTrack,
                configuration: monitorQuality.outputEncoderConfiguration
            )
            encoderStats = await programEncoder.stats()
        }
    }

    private func observeProgramAudioEncoder() {
        audioEncoderTask?.cancel()
        audioEncoderTask = Task {
            for await event in await programAudioEncoder.events() {
                guard !Task.isCancelled else { break }
                switch event {
                case .started:
                    await refreshAudioStatsIfNeeded(force: true)
                case .sample(let sample):
                    await broadcastPublisher.sendAudio(sample)
                    await refreshAudioStatsIfNeeded(force: false)
                case .stopped:
                    audioEncoderStats = AudioEncoderStats()
                    lastAudioStatsRefresh = .distantPast
                case .failed(let message):
                    lastError = message
                }
            }
        }
    }

    private func refreshAudioStatsIfNeeded(force: Bool) async {
        let now = Date()
        guard force || now.timeIntervalSince(lastAudioStatsRefresh) >= statsRefreshInterval else { return }
        lastAudioStatsRefresh = now
        audioEncoderStats = await programAudioEncoder.stats()
    }

    private func syncProgramAudioEncoder() {
        Task {
            guard programAudioSourceID != nil else {
                await programAudioEncoder.stop()
                audioEncoderStats = AudioEncoderStats()
                return
            }
            await programAudioEncoder.start()
            audioEncoderStats = await programAudioEncoder.stats()
        }
    }

    private func observeBroadcastPublisher() {
        publisherTask?.cancel()
        publisherTask = Task {
            for await event in await broadcastPublisher.events() {
                guard !Task.isCancelled else { break }
                switch event {
                case .stateChanged(let state):
                    publisherStats = await broadcastPublisher.currentStats()
                    publisherStats.state = state
                case .failed(let message):
                    publisherStats.state = .failed
                    lastError = message
                }
            }
        }
    }

    private func restoreFacebookSession() {
        facebookSession = FacebookSessionStore.load()
        guard facebookSession.isSignedIn else { return }
        Task { await refreshFacebookPages() }
    }

    private func refreshFacebookPages() async {
        guard facebookSession.isSignedIn else { return }
        do {
            facebookPages = try await facebookLive.fetchPages(for: facebookSession)
            if facebookSession.selectedPageID == nil, let first = facebookPages.first {
                facebookSession.selectedPageID = first.id
                FacebookSessionStore.save(facebookSession)
            }
        } catch {
            facebookStatusMessage = error.localizedDescription
        }
    }

    private func endFacebookLiveIfNeeded() async {
        guard facebookSession.activeLiveVideoID != nil,
              let pageID = facebookSession.selectedPageID,
              let page = facebookPages.first(where: { $0.id == pageID }) else { return }

        do {
            try await facebookLive.endLiveBroadcast(session: facebookSession, page: page)
            facebookSession = FacebookSessionStore.load()
            facebookStatusMessage = "Transmisión de Facebook finalizada"
        } catch {
            lastError = error.localizedDescription
        }
    }
}
