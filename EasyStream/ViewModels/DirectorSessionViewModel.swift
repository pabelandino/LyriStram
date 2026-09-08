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
    var connectionStateUpdatedAt: Date = Date()

    static func == (lhs: ConnectedCameraSource, rhs: ConnectedCameraSource) -> Bool {
        lhs.id == rhs.id
            && lhs.displayName == rhs.displayName
            && lhs.connectionState == rhs.connectionState
            && lhs.remoteSettings == rhs.remoteSettings
            && lhs.videoTrack === rhs.videoTrack
            && lhs.audioTrack === rhs.audioTrack
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
            CameraTransportProfile.directorQuality = monitorQuality.effectiveSettings().effectiveSettings()
            scheduleMonitorQualityBroadcast()
            broadcastSwitcherAssignments()
            syncProgramEncoder()
        }
    }

    /// Applies quality from an auxiliary panel — preserves PROG-affecting fields while on-air.
    func applyMonitorQuality(_ proposed: DirectorMonitorQualitySettings) {
        let merged = DirectorLiveOutputGuard.mergedQualityUpdate(
            programSourceID: programSourceID,
            isTransitioning: isTransitioning,
            isPublishing: isPublishing,
            current: monitorQuality,
            proposed: proposed
        )
        monitorQuality = merged
    }

    private var effectiveMonitorQuality: DirectorMonitorQualitySettings {
        monitorQuality.effectiveSettings()
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
    private var stuckSourceWatchTask: Task<Void, Never>?
    private var monitorQualityBroadcastTask: Task<Void, Never>?
    /// Serializes preview/take mutations so concurrent Tasks cannot apply switcher state out of order.
    private var switcherQueueTail: Task<Void, Never>?
    private var lastEncoderStatsRefresh = Date.distantPast
    private var lastAudioStatsRefresh = Date.distantPast
    private let statsRefreshInterval: TimeInterval = 2.0
    /// H.264 program encoder runs only while RTMP/network publish is active — not during normal monitoring.
    private var isStreamEncodingEnabled = false
    private var lastBroadcastAssignments: [CameraSourceID: CameraSwitcherAssignment] = [:]

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
    var programBusIncomingTrack: RTCVideoTrack? {
        if isTransitioning {
            return transitionIncomingVideoTrack
        }
        if let takeHandoffSourceID {
            return track(for: takeHandoffSourceID)
        }
        if programSourceID != nil {
            return warmedPreviewVideoTrack
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

    var activeStreamingSourceCount: Int {
        sources.filter { switcherAssignment(for: $0.id).isActive }.count
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

        CameraTransportProfile.directorQuality = monitorQuality.effectiveSettings()

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
                scheduleMonitorQualityBroadcast(force: true)
                startStuckSourceWatch()
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
        stuckSourceWatchTask?.cancel()
        monitorQualityBroadcastTask?.cancel()
        sources = []
        lastBroadcastAssignments = [:]
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
        enqueueSwitcherOperation {
            await self.selectPreviewAndSync(sourceID)
        }
    }

    func selectPreviewAndSync(_ sourceID: CameraSourceID) async {
        guard takeHandoffSourceID == nil else { return }
        inspectorSourceID = sourceID
        guard previewSourceID != sourceID else {
            syncRemoteVideoTrackPolicy()
            return
        }
        // On-air source stays on the program bus — preview lane is for the next take target only.
        guard sourceID != programSourceID else {
            syncRemoteVideoTrackPolicy()
            return
        }
        if let event = await switcher.setPreview(sourceID) {
            applySwitcherEvent(event)
        }
        syncRemoteVideoTrackPolicy()
    }

    func takeToProgram() {
        guard !isTransitioning else { return }
        guard takeHandoffSourceID == nil else { return }
        switcherQueueTail?.cancel()
        switcherQueueTail = Task { @MainActor in
            await self.performTakeToProgram()
        }
    }

    private func enqueueSwitcherOperation(_ operation: @escaping @MainActor () async -> Void) {
        let previous = switcherQueueTail
        switcherQueueTail = Task { @MainActor in
            await previous?.value
            await operation()
        }
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

        guard let incoming = await waitForVideoTrack(sourceID: target) else {
            lastError = "La cámara en preview aún no tiene señal de video."
            statusMessage = "Espera a que la cámara conecte antes de llevarla al aire."
            return
        }

        takeHandoffSourceID = target
        transitionIncomingVideoTrack = incoming

        if transition.kind == .cut || transition.duration <= 0 {
            ProgramBusTrace.event(
                "director take cut begin target=\(ProgramBusTrace.shortSourceID(target.rawValue)) prevProgram=\(ProgramBusTrace.shortSourceID(programSourceID?.rawValue)) preview=\(ProgramBusTrace.shortSourceID(previewSourceID?.rawValue))"
            )
            outgoingProgramSourceID = nil
            transitionProgress = 1
            isTransitioning = false

            ProgramFrameDisplayBus.shared.beginSubHDOnAirGracePeriod()
            await preRampTakeTargetToProgram(target)

            if effectiveMonitorQuality.prefetchTakeTarget {
                let ready = await ProgramFrameDisplayBus.shared.waitForIncomingProgramThreshold(
                    maxAttempts: 45,
                    intervalMs: 16
                )
                ProgramBusTrace.event(
                    "director take cut prewarm ready=\(ready) incomingHD=\(ProgramFrameDisplayBus.shared.incomingMeetsProgramDisplayThreshold())"
                )
            }

            let events = await switcher.take(to: target, transition: transition)
            applySwitcherEvents(events)
            await broadcastSwitcherAssignmentsNow()
            ProgramBusTrace.event(
                "director take cut end program=\(ProgramBusTrace.shortSourceID(programSourceID?.rawValue)) preview=\(ProgramBusTrace.shortSourceID(previewSourceID?.rawValue)) incomingTrack=\(ProgramBusTrace.shortTrackId(incoming.trackId))"
            )
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
        await broadcastSwitcherAssignmentsNow()
        outgoingProgramSourceID = nil
        isTransitioning = false
        await completeTakeHandoff()
    }

    /// Lets compositor finish handoff while take target remains pinned by source ID.
    private func completeTakeHandoff() async {
        await Task.yield()
        takeHandoffSourceID = nil
        transitionIncomingVideoTrack = nil
        syncRemoteVideoTrackPolicy()
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

    /// Starts program-tier encode on the take target before the switcher flips state.
    private func preRampTakeTargetToProgram(_ target: CameraSourceID) async {
        let assignment = CameraSwitcherAssignment.program
        guard lastBroadcastAssignments[target] != assignment else { return }
        lastBroadcastAssignments[target] = assignment
        ProgramBusTrace.event(
            "director pre-ramp take target=\(ProgramBusTrace.shortSourceID(target.rawValue)) -> program"
        )
        try? await streamReceiver.sendControl(
            to: target,
            command: .setSwitcherAssignment(assignment)
        )
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
            } catch DirectorStreamError.sourceNotConnected {
                sources.removeAll { $0.id == sourceID }
                lastBroadcastAssignments.removeValue(forKey: sourceID)
                await switcher.unregisterSource(sourceID)
                await syncSwitcherState()
                statusMessage = "Esperando que la cámara vuelva a conectar…"
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
        sources[index].connectionStateUpdatedAt = Date()
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
            enqueueSwitcherOperation {
                let saved = await self.settingsStore.settings(for: sourceID)
                self.upsertSource(sourceID, displayName: displayName, connectionState: .connecting, remoteSettings: saved)
                _ = await self.switcher.registerSource(sourceID)
                await self.syncSwitcherState()
                if self.inspectorSourceID == nil { self.inspectorSourceID = sourceID }
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
            track.isEnabled = false
            upsertSource(sourceID, displayName: displayName, videoTrack: track, connectionState: .connected)
            statusMessage = "\(connectedSourceCount) cámara(s) en vivo"
            if previewSourceID == nil {
                enqueueSwitcherOperation {
                    await self.selectPreviewAndSync(sourceID)
                }
            }
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
            if let connectionState {
                if source.connectionState != connectionState {
                    source.connectionStateUpdatedAt = Date()
                }
                source.connectionState = connectionState
            }
            if let remoteSettings { source.remoteSettings = remoteSettings }
            sources[index] = source
        } else {
            sources.append(ConnectedCameraSource(
                id: sourceID,
                displayName: displayName ?? "Cámara",
                videoTrack: videoTrack,
                audioTrack: audioTrack,
                connectionState: connectionState ?? .connecting,
                remoteSettings: remoteSettings ?? RemoteCameraSettings(),
                connectionStateUpdatedAt: Date()
            ))
        }
        sources.sort { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
        syncPreviewMonitor()
        broadcastSwitcherAssignments()
        if videoTrack != nil {
            scheduleMonitorQualityBroadcast()
        }
        syncRemoteVideoTrackPolicy()
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
        Task { await broadcastSwitcherAssignmentsNow() }
    }

    private func broadcastSwitcherAssignmentsNow() async {
        syncRemoteVideoTrackPolicy()
        var pending: [(CameraSourceID, CameraSwitcherAssignment)] = []
        for source in sources {
            let assignment = switcherAssignment(for: source.id)
            if lastBroadcastAssignments[source.id] != assignment {
                lastBroadcastAssignments[source.id] = assignment
                pending.append((source.id, assignment))
            }
        }
        for (sourceID, assignment) in pending where assignment.isActive {
            ProgramBusTrace.event(
                "director assignment source=\(ProgramBusTrace.shortSourceID(sourceID.rawValue)) -> \(assignment.rawValue)"
            )
        }
        guard !pending.isEmpty else { return }
        await withTaskGroup(of: Void.self) { group in
            for (sourceID, assignment) in pending {
                group.addTask {
                    try? await self.streamReceiver.sendControl(
                        to: sourceID,
                        command: .setSwitcherAssignment(assignment)
                    )
                }
            }
        }
    }

    private func broadcastMonitorQuality() {
        let quality = effectiveMonitorQuality
        for source in sources {
            Task {
                try? await streamReceiver.sendControl(
                    to: source.id,
                    command: .setDirectorMonitorQuality(quality)
                )
            }
        }
    }

    /// Idle sources stop decoding on the director — preview + program lanes are never disabled while on-air.
    private func syncRemoteVideoTrackPolicy() {
        for source in sources {
            guard let track = source.videoTrack else { continue }
            let assignment = switcherAssignment(for: source.id)
            track.isEnabled = DirectorLiveOutputGuard.shouldKeepTrackDecoding(
                sourceID: source.id,
                programSourceID: programSourceID,
                previewSourceID: previewSourceID,
                assignmentIsActive: assignment.isActive
            )
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
        updateAudioRouting()
        syncPreviewMonitor()
        await broadcastSwitcherAssignmentsNow()
        scheduleMonitorQualityBroadcast(force: true)
        syncRemoteVideoTrackPolicy()
        syncProgramAudioEncoder()
    }

    private func scheduleMonitorQualityBroadcast(force: Bool = false) {
        monitorQualityBroadcastTask?.cancel()
        monitorQualityBroadcastTask = Task {
            if !force {
                try? await Task.sleep(for: .milliseconds(400))
            }
            guard !Task.isCancelled else { return }
            broadcastMonitorQuality()
        }
    }

    private func startStuckSourceWatch() {
        stuckSourceWatchTask?.cancel()
        stuckSourceWatchTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(10))
                guard !Task.isCancelled else { break }
                reconcileStuckSources()
            }
        }
    }

    private func reconcileStuckSources() {
        let staleThreshold: TimeInterval = 18
        let now = Date()
        for source in sources {
            let age = now.timeIntervalSince(source.connectionStateUpdatedAt)
            switch source.connectionState {
            case .connecting, .signaling where age >= staleThreshold:
                reconnectCamera(source.id)
            case .connected where source.videoTrack == nil && age >= staleThreshold:
                reconnectCamera(source.id)
            default:
                break
            }
        }
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
            // Decode mic audio only for the on-air source — preview tiles are video-only.
            let onAir = source.id == programSourceID && source.id == programAudioSourceID
            source.audioTrack?.isEnabled = onAir
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
