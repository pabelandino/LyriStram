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
    var platform: DevicePlatform = .unknown
    var connectionStateUpdatedAt: Date = Date()

    static func == (lhs: ConnectedCameraSource, rhs: ConnectedCameraSource) -> Bool {
        lhs.id == rhs.id
            && lhs.displayName == rhs.displayName
            && lhs.connectionState == rhs.connectionState
            && lhs.remoteSettings == rhs.remoteSettings
            && lhs.platform == rhs.platform
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
    private(set) var listeningPort: UInt16?
    private(set) var localIPv4Addresses: [String] = []
    private(set) var advertisedConnectHost = ""
    private(set) var needsLocalNetworkPermission = false
    private(set) var previewSourceID: CameraSourceID?
    private(set) var programSourceID: CameraSourceID?
    /// True after the first camera tap has been placed on PROG. Later taps follow the normal cut rules.
    private var didPlaceOpeningProgram = false
    /// Camera the program monitor is reading. Independent from the next-preview tally, so a cut cannot snap the picture back.
    private(set) var monitorSourceID: CameraSourceID?
    private(set) var programAudioSourceID: CameraSourceID?
    private(set) var selectedProgramAudioInput: DirectorProgramAudioInput?
    private var audioInputBeforeVideo: DirectorProgramAudioInput?
    private var audioFollowedVideoID: UUID?
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

    let selectedTransition: SwitchTransition = .cut

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
    /// Drops a finished take that was replaced by a newer camera change.
    private var takeGeneration: UInt = 0

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
    private var pictureLatencyTask: Task<Void, Never>?
    private var publisherTask: Task<Void, Never>?
    private var stuckSourceWatchTask: Task<Void, Never>?
    private var monitorQualityBroadcastTask: Task<Void, Never>?
    private var previewAssignmentBroadcastTask: Task<Void, Never>?
    /// Prefetch target — incoming lane follows the selected preview immediately.
    private(set) var incomingWarmPreviewSourceID: CameraSourceID?
    private var lastBroadcastMonitorQuality: DirectorMonitorQualitySettings?
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

    /// Incoming lane wired into the compositor (handoff pin or debounced preview warm — single entry point).
    var programBusIncomingTrack: RTCVideoTrack? {
        if fullScreenMediaCoversProgram { return nil }
        if isTransitioning {
            return transitionIncomingVideoTrack
        }
        if let takeHandoffSourceID {
            return track(for: takeHandoffSourceID)
        }
        guard let previewSourceID,
              previewSourceID != programSourceID else { return nil }

        if programSourceID == nil, showsOffAirPreviewOnProgramMonitor {
            return track(for: previewSourceID)
        }

        guard monitorQuality.prefetchTakeTarget else { return nil }
        guard let warmID = incomingWarmPreviewSourceID, warmID != programSourceID else { return nil }
        return track(for: warmID)
    }

    /// On air shows program. Off air shows the selected preview so the monitor is not black.
    var programDisplayTrack: RTCVideoTrack? {
        if fullScreenMediaCoversProgram { return nil }
        if isTransitioning {
            return outgoingProgramVideoTrack ?? programVideoTrack
        }
        if programSourceID != nil {
            return programVideoTrack
        }
        return previewVideoTrack
    }

    /// Before the first take, the large monitor follows the selected camera.
    var showsOffAirPreviewOnProgramMonitor: Bool {
        if fullScreenMediaCoversProgram { return false }
        return programSourceID == nil && previewVideoTrack != nil
    }

    /// An image, video, or full-screen Lyriora plate owns the program picture.
    private var fullScreenMediaCoversProgram: Bool {
        LiveProgramAirStore.shared.fullScreenIsLive || LiveProgramAirStore.shared.lyrioraCoversProgram
    }

    /// Camera that was on air before a full-screen Lyriora plate took the picture.
    private var programSourceBeforeLyrioraFullScreen: CameraSourceID?
    private var suppressLyrioraRestore = false

    /// Clears the live picture the way a full-screen resource does, and remembers what to bring back.
    func coverProgramWithLyrioraFullScreen() {
        if programSourceBeforeLyrioraFullScreen == nil {
            programSourceBeforeLyrioraFullScreen = programSourceID ?? previewSourceID
        }
        if LiveProgramAirStore.shared.fullScreenIsLive {
            DirectorWorkspaceSession.shared.mediaViewModel?.removeFullScreenFromLive()
        }
        if programSourceID != nil {
            leaveAir()
        }
    }

    /// Puts the remembered signal back when the full-screen plate leaves the air.
    func restoreProgramAfterLyrioraFullScreen() {
        if suppressLyrioraRestore {
            suppressLyrioraRestore = false
            programSourceBeforeLyrioraFullScreen = nil
            return
        }
        guard let source = programSourceBeforeLyrioraFullScreen else { return }
        programSourceBeforeLyrioraFullScreen = nil
        guard programSourceID == nil, track(for: source) != nil else { return }
        takeToProgram(target: source)
    }

    /// A manual camera take owns the picture. Do not put the previous signal back on top of it.
    func cancelLyrioraProgramRestore() {
        guard programSourceBeforeLyrioraFullScreen != nil else { return }
        suppressLyrioraRestore = true
        programSourceBeforeLyrioraFullScreen = nil
    }

    /// Drops the live camera so a full-screen image or video is what the program transmits.
    func yieldProgramPictureToMedia() {
        guard programSourceID != nil else { return }
        leaveAir()
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
        observePictureLatency()
        observeBroadcastPublisher()
        restoreFacebookSession()

        CameraTransportProfile.directorQuality = monitorQuality.effectiveSettings()

        Task {
            await discovery.setIncomingConnectionHandler { [streamReceiver] connection in
                Task { await streamReceiver.handleIncomingConnection(connection) }
            }

            do {
                refreshLocalAddresses()
                try await discovery.start(
                    role: .director,
                    identity: identity,
                    connectHost: advertisedConnectHost.isEmpty ? nil : advertisedConnectHost
                )
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
                refreshLocalAddresses()
                try await discovery.start(
                    role: .director,
                    identity: identity,
                    connectHost: advertisedConnectHost.isEmpty ? nil : advertisedConnectHost
                )
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
        pictureLatencyTask?.cancel()
        publisherTask?.cancel()
        stuckSourceWatchTask?.cancel()
        monitorQualityBroadcastTask?.cancel()
        previewAssignmentBroadcastTask?.cancel()
        incomingWarmPreviewSourceID = nil
        DirectorPreviewWarmupTour.reset()
        DirectorRemoteVideoTrackPolicy.reset()
        DirectorTileThumbnailCoordinator.reset()
        lastBroadcastMonitorQuality = nil
        sources = []
        lastBroadcastAssignments = [:]
        previewSourceID = nil
        monitorSourceID = nil
        programSourceID = nil
        didPlaceOpeningProgram = false
        programAudioSourceID = nil
        selectedProgramAudioInput = nil
        ProgramAudioMonitor.shared.setFeedsLiveVideo(false)
        ProgramAudioMonitor.shared.setUsesLocalInput(false, uid: nil)
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
        // The camera list and the remote controls (lens, zoom, exposure) follow the same tap.
        inspectorSourceID = sourceID
        // The first camera with a picture goes to PROG so a later full-screen image can replace a real source.
        if !didPlaceOpeningProgram, programSourceID == nil {
            if previewSourceID != sourceID {
                previewSourceID = sourceID
                monitorSourceID = sourceID
                incomingWarmPreviewSourceID = sourceID
                syncRemoteVideoTrackPolicy()
                syncPreviewMonitor()
                schedulePreviewAssignmentBroadcast(to: sourceID)
            }
            guard track(for: sourceID) != nil else { return }
            didPlaceOpeningProgram = true
            takeToProgram(target: sourceID)
            return
        }

        // Already live: the camera the operator picks replaces program immediately.
        if programSourceID != nil, sourceID != programSourceID {
            previewSourceID = sourceID
            monitorSourceID = sourceID
            incomingWarmPreviewSourceID = sourceID
            syncPreviewMonitor()
            takeToProgram(target: sourceID)
            return
        }

        guard sourceID != programSourceID else {
            syncRemoteVideoTrackPolicy()
            return
        }
        guard previewSourceID != sourceID else {
            syncRemoteVideoTrackPolicy()
            return
        }

        // Optimistic UI — transport and network stay debounced.
        previewSourceID = sourceID
        monitorSourceID = sourceID
        if programSourceID == nil {
            DirectorDecodedSignalCache.shared.setLiveSelection(sourceID)
        }
        syncRemoteVideoTrackPolicy()
        syncPreviewMonitor()
        // Warm the program incoming lane immediately so the next cut already has frames.
        if programSourceID != nil, sourceID != programSourceID, monitorQuality.prefetchTakeTarget {
            incomingWarmPreviewSourceID = sourceID
        } else if programSourceID == nil {
            incomingWarmPreviewSourceID = nil
        }
        schedulePreviewAssignmentBroadcast(to: sourceID)
    }

    func selectPreviewAndSync(_ sourceID: CameraSourceID) async {
        selectPreview(sourceID)
        await previewAssignmentBroadcastTask?.value
    }

    private func schedulePreviewAssignmentBroadcast(to sourceID: CameraSourceID) {
        previewAssignmentBroadcastTask?.cancel()
        previewAssignmentBroadcastTask = Task {
            guard !Task.isCancelled, previewSourceID == sourceID else { return }
            _ = await switcher.setPreview(sourceID)
            await broadcastSwitcherAssignmentsNow()
        }
    }

    func takeToProgram() {
        guard let previewSourceID else { return }
        takeToProgram(target: previewSourceID)
    }

    func takeToProgram(target: CameraSourceID) {
        takeGeneration &+= 1
        let generation = takeGeneration
        switcherQueueTail?.cancel()
        switcherQueueTail = Task { @MainActor in
            await self.performTakeToProgram(generation: generation, target: target)
        }
    }

    /// Drops the live program. Preview stays selected for the next take.
    func leaveAir() {
        guard programSourceID != nil else { return }
        takeGeneration &+= 1
        let generation = takeGeneration
        isTransitioning = false
        takeHandoffSourceID = nil
        outgoingProgramSourceID = nil
        transitionIncomingVideoTrack = nil
        transitionProgress = 0
        switcherQueueTail?.cancel()
        switcherQueueTail = Task { @MainActor in
            let events = await switcher.clearProgram()
            guard generation == takeGeneration else { return }
            applySwitcherEvents(events)
            statusMessage = "Fuera del aire"
            if let previewSourceID {
                DirectorDecodedSignalCache.shared.setLiveSelection(previewSourceID)
            } else {
                DirectorDecodedSignalCache.shared.setDisplayTracks(onAir: nil, incoming: nil, outgoing: nil)
            }
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

    private func performTakeToProgram(generation: UInt, target: CameraSourceID) async {
        cancelLyrioraProgramRestore()
        DirectorWorkspaceSession.shared.mediaViewModel?.releaseProgramMediaForCameraTake()
        let previousProgram = await switcher.state.programSourceID
        guard generation == takeGeneration else { return }
        guard previousProgram != target else { return }
        guard track(for: target) != nil else {
            if programSourceID == nil {
                didPlaceOpeningProgram = false
            }
            lastError = "La cámara en preview aún no tiene señal de video."
            statusMessage = "Espera a que la cámara conecte antes de llevarla al aire."
            return
        }

        await switcher.setPreferredTransition(.cut)
        guard generation == takeGeneration else { return }
        let events = await switcher.take(to: target, transition: .cut)
        guard generation == takeGeneration else { return }

        previewSourceID = target
        monitorSourceID = target
        incomingWarmPreviewSourceID = target
        isTransitioning = false
        transitionProgress = 1
        outgoingProgramSourceID = nil
        transitionIncomingVideoTrack = nil
        takeHandoffSourceID = nil
        applySwitcherEvents(events)
        DirectorDecodedSignalCache.shared.setLiveSelection(target)
        Task { await broadcastSwitcherAssignmentsNow() }
    }

    func setProgramAudioSource(_ sourceID: CameraSourceID) {
        selectProgramAudio(.camera(sourceID))
    }

    func selectProgramAudio(_ input: DirectorProgramAudioInput) {
        switch input {
        case .camera(let sourceID):
            audioInputBeforeVideo = input
            selectedProgramAudioInput = input
            ProgramAudioMonitor.shared.setFeedsLiveVideo(false)
            ProgramAudioMonitor.shared.setUsesLocalInput(false, uid: nil)
            Task {
                if let event = await switcher.setProgramAudioSource(sourceID) {
                    applySwitcherEvent(event)
                }
                updateAudioRouting()
                syncProgramAudioEncoder()
            }
        case .liveVideo:
            if selectedProgramAudioInput != .liveVideo {
                audioInputBeforeVideo = selectedProgramAudioInput
            }
            selectedProgramAudioInput = input
            ProgramAudioMonitor.shared.setUsesLocalInput(false, uid: nil)
            ProgramAudioMonitor.shared.setFeedsLiveVideo(true)
            updateAudioRouting()
            syncProgramAudioEncoder()
        case .localDevice(let uid):
            audioInputBeforeVideo = input
            selectedProgramAudioInput = input
            ProgramAudioMonitor.shared.setFeedsLiveVideo(false)
            ProgramAudioMonitor.shared.setUsesLocalInput(true, uid: uid)
            updateAudioRouting()
            syncProgramAudioEncoder()
        }
    }

    /// A library video on air plays through the monitor output and the transmission.
    /// Passing the same id again does not override a source the operator picked afterwards.
    func syncAudioWithProgramPlate(videoID: UUID?) {
        if let videoID {
            guard audioFollowedVideoID != videoID else { return }
            audioFollowedVideoID = videoID
            selectProgramAudio(.liveVideo)
            return
        }
        guard audioFollowedVideoID != nil else { return }
        audioFollowedVideoID = nil
        guard selectedProgramAudioInput == .liveVideo else { return }
        if let previous = audioInputBeforeVideo, previous != .liveVideo {
            selectProgramAudio(previous)
        } else if let programAudioSourceID {
            selectProgramAudio(.camera(programAudioSourceID))
        } else {
            selectedProgramAudioInput = nil
            ProgramAudioMonitor.shared.setFeedsLiveVideo(false)
            updateAudioRouting()
            syncProgramAudioEncoder()
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
                markSourceDisconnected(sourceID)
                statusMessage = "Sin enlace con la cámara. Quedó desconectada."
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
        sources[index].audioTrack = nil
        sources[index].connectionState = .connecting
        sources[index].connectionStateUpdatedAt = Date()
        syncPreviewMonitor()
    }

    private func markSourceDisconnected(_ sourceID: CameraSourceID) {
        guard let index = sources.firstIndex(where: { $0.id == sourceID }) else { return }
        sources[index].videoTrack = nil
        sources[index].audioTrack = nil
        sources[index].connectionState = .disconnected
        sources[index].connectionStateUpdatedAt = Date()
        syncPreviewMonitor()
        syncRemoteVideoTrackPolicy()
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
        case .advertisingReady(let port):
            listeningPort = port
        }
    }

    func applyAdvertisedConnectHost(_ host: String) {
        let trimmed = host.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.isIPv4(trimmed) else {
            lastError = "Escribe una dirección IPv4, por ejemplo 192.168.1.20"
            return
        }
        lastError = nil
        advertisedConnectHost = trimmed
        UserDefaults.standard.set(trimmed, forKey: Self.connectHostDefaultsKey)
        Task {
            do {
                try await discovery.setAdvertisedHost(trimmed)
            } catch {
                lastError = error.localizedDescription
            }
        }
    }

    private func refreshLocalAddresses() {
        localIPv4Addresses = LocalInterfaceAddresses.ipv4()
        if let saved = UserDefaults.standard.string(forKey: Self.connectHostDefaultsKey), Self.isIPv4(saved) {
            advertisedConnectHost = saved
        } else if advertisedConnectHost.isEmpty, let first = localIPv4Addresses.first {
            advertisedConnectHost = first
        }
    }

    private static let connectHostDefaultsKey = "com.easystream.directorConnectHost"

    private static func isIPv4(_ value: String) -> Bool {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 4 else { return false }
        return parts.allSatisfy { part in
            guard let number = Int(part), (0...255).contains(number) else { return false }
            return true
        }
    }

    private func handleStreamEvent(_ event: DirectorStreamReceiver.Event) {
        switch event {
        case .sourceConnected(let sourceID, let displayName, let platform):
            enqueueSwitcherOperation {
                await self.refreshDevices()
                let saved = await self.settingsStore.settings(for: sourceID)
                self.upsertSource(
                    sourceID,
                    displayName: displayName,
                    connectionState: .connecting,
                    remoteSettings: saved,
                    signaledPlatform: platform
                )
                _ = await self.switcher.registerSource(sourceID)
                await self.syncSwitcherState()
                if self.inspectorSourceID == nil { self.inspectorSourceID = sourceID }
            }
            statusMessage = "\(displayName) conectada"

        case .sourceDisconnected(let sourceID):
            markSourceDisconnected(sourceID)
            DirectorSourceThumbnailBus.shared.remove(sourceID: sourceID)
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
            if state == .disconnected || state == .failed {
                markSourceDisconnected(sourceID)
            } else {
                upsertSource(sourceID, connectionState: state)
            }

        case .sourceSettingsUpdated(let sourceID, let settings):
            Task {
                await settingsStore.save(settings, for: sourceID)
                upsertSource(sourceID, remoteSettings: settings)
            }

        case .sourceTileSnapshot(let sourceID, let jpeg, let sequence):
            DirectorSourceThumbnailBus.shared.publishJPEG(sourceID: sourceID, jpeg: jpeg, sequence: sequence)
            TileThumbnailTrace.eventThrottled(
                "director-jpeg-\(sourceID.rawValue.uuidString.prefix(8))",
                intervalMs: 3_000,
                "director idle jpeg received source=\(ProgramBusTrace.shortSourceID(sourceID.rawValue)) bytes=\(jpeg.count) seq=\(sequence)"
            )

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
        remoteSettings: RemoteCameraSettings? = nil,
        signaledPlatform: DevicePlatform? = nil
    ) {
        if let index = sources.firstIndex(where: { $0.id == sourceID }) {
            var source = sources[index]
            if let displayName {
                source.displayName = resolvedDisplayName(for: sourceID, signalingName: displayName)
            }
            if let videoTrack {
                if source.videoTrack !== videoTrack {
                    DirectorRemoteVideoTrackPolicy.invalidate(sourceID: sourceID)
                }
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
            if let signaledPlatform, signaledPlatform != .unknown {
                source.platform = signaledPlatform
            } else {
                let resolvedPlatform = platform(for: sourceID)
                if resolvedPlatform != .unknown {
                    source.platform = resolvedPlatform
                }
            }
            sources[index] = source
        } else {
            let name = resolvedDisplayName(for: sourceID, signalingName: displayName)
            let resolvedPlatform: DevicePlatform = {
                if let signaledPlatform, signaledPlatform != .unknown { return signaledPlatform }
                return platform(for: sourceID)
            }()
            sources.append(ConnectedCameraSource(
                id: sourceID,
                displayName: name,
                videoTrack: videoTrack,
                audioTrack: audioTrack,
                connectionState: connectionState ?? .connecting,
                remoteSettings: remoteSettings ?? RemoteCameraSettings(),
                platform: resolvedPlatform,
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
                if id == nil {
                    incomingWarmPreviewSourceID = nil
                } else if let preview = previewSourceID, preview != id {
                    incomingWarmPreviewSourceID = preview
                }
            case .programAudioChanged(let id):
                programAudioSourceID = id
                if selectedProgramAudioInput == nil, let id {
                    selectedProgramAudioInput = .camera(id)
                }
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
        guard quality != lastBroadcastMonitorQuality else { return }
        lastBroadcastMonitorQuality = quality
        for source in sources {
            Task {
                try? await streamReceiver.sendControl(
                    to: source.id,
                    command: .setDirectorMonitorQuality(quality)
                )
            }
        }
    }

    /// Idle sources stop decoding on the director — only mutates tracks whose role changed.
    private func syncRemoteVideoTrackPolicy() {
        let quality = monitorQuality.effectiveSettings()
        DirectorPreviewTileTrackPolicy.visibilityPolicy = .allConnectedSources

        DirectorRemoteVideoTrackPolicy.applyDiff(
            sources: sources,
            previewSourceID: previewSourceID,
            programSourceID: programSourceID,
            decodeAllConnectedFeeds: true,
            assignmentFor: { switcherAssignment(for: $0) }
        )
        let tracks = Dictionary(uniqueKeysWithValues: sources.map { ($0.id, $0.videoTrack) })
        DirectorDecodedSignalCache.shared.sync(sources: tracks)
        DirectorTileThumbnailCoordinator.sync(
            sources: tracks,
            previewSourceID: previewSourceID,
            programSourceID: programSourceID,
            idleThumbnailsEnabled: quality.idleTileSnapshotsEnabled || !quality.pauseIdleCameraStreams
        )
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
        let staleThreshold: TimeInterval = 12
        let now = Date()
        for source in sources {
            let age = now.timeIntervalSince(source.connectionStateUpdatedAt)
            switch source.connectionState {
            case .connecting, .signaling, .failed where age >= staleThreshold:
                releaseStuckSource(source.id)
            case .connected where source.videoTrack == nil && age >= staleThreshold:
                releaseStuckSource(source.id)
            default:
                break
            }
        }
    }

    /// Closes a dead director link and leaves the camera in the list as disconnected.
    private func releaseStuckSource(_ sourceID: CameraSourceID) {
        Task {
            await streamReceiver.releaseSource(sourceID)
            markSourceDisconnected(sourceID)
            statusMessage = "Sin conexión con \(inspectorSourceName(for: sourceID)). Quedó desconectada."
        }
    }

    private func track(for sourceID: CameraSourceID?) -> RTCVideoTrack? {
        guard let sourceID else { return nil }
        return sources.first { $0.id == sourceID }?.videoTrack
    }

    private func platform(for sourceID: CameraSourceID) -> DevicePlatform {
        if let source = sources.first(where: { $0.id == sourceID }), source.platform != .unknown {
            return source.platform
        }
        return devices.first(where: { $0.id == sourceID.rawValue })?.platform ?? .unknown
    }

    private func refreshDevices() async {
        devices = await discovery.discoveredDevices
        syncSourceMetadataFromDiscovery()
    }

    private func resolvedDisplayName(for sourceID: CameraSourceID, signalingName: String?) -> String {
        if let device = devices.first(where: { $0.id == sourceID.rawValue }),
           !device.displayName.isEmpty {
            return device.displayName
        }
        if let signalingName, !signalingName.isEmpty {
            return signalingName
        }
        return "Cámara"
    }

    private func syncSourceMetadataFromDiscovery() {
        guard !devices.isEmpty else { return }
        var changed = false
        for index in sources.indices {
            let sourceID = sources[index].id
            guard let device = devices.first(where: { $0.id == sourceID.rawValue }) else { continue }
            if !device.displayName.isEmpty, sources[index].displayName != device.displayName {
                sources[index].displayName = device.displayName
                changed = true
            }
            if device.platform != .unknown, sources[index].platform != device.platform {
                sources[index].platform = device.platform
                changed = true
            }
        }
        if changed {
            syncPreviewMonitor()
        }
    }

    private func updateAudioRouting() {
        let cameraAudioID: CameraSourceID?
        if case .camera(let sourceID) = selectedProgramAudioInput {
            cameraAudioID = sourceID
        } else if selectedProgramAudioInput == nil {
            cameraAudioID = programAudioSourceID
        } else {
            cameraAudioID = nil
        }
        for source in sources {
            source.audioTrack?.isEnabled = source.id == cameraAudioID
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
            let hasSource = selectedProgramAudioInput != nil || programAudioSourceID != nil
            guard hasSource else {
                await programAudioEncoder.stop()
                audioEncoderStats = AudioEncoderStats()
                return
            }
            await programAudioEncoder.start()
            audioEncoderStats = await programAudioEncoder.stats()
        }
    }

    private func observePictureLatency() {
        pictureLatencyTask?.cancel()
        pictureLatencyTask = Task {
            while !Task.isCancelled {
                let delay = await streamReceiver.videoReceptionDelayMs(for: programSourceID ?? programAudioSourceID)
                ProgramAudioMonitor.shared.notePictureLatency(delay)
                try? await Task.sleep(for: .seconds(1))
            }
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
