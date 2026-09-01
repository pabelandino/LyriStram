import AVFoundation
import Foundation
import Network
import EasyStreamCore

#if canImport(UIKit)
import UIKit
#endif

@MainActor
@Observable
public final class TeamIntercomService {
    public enum State: Equatable {
        case stopped
        case starting
        case ready
        case failed(String)
    }

    public private(set) var state: State = .stopped
    public private(set) var peers: [TeamIntercomPeer] = []
    public private(set) var isTalking = false
    public private(set) var isActivating = false
    public var isEnabled = true
    public private(set) var targetPeerID: UUID?
    public private(set) var statusMessage = "Intercom desactivado"
    public private(set) var needsLocalNetworkPermission = false

    private var listener: NWListener?
    private var browser: NWBrowser?
    private var connections: [UUID: NWConnection] = [:]
    private var readyPeerConnections: Set<UUID> = []
    private var inboundConnections: [ObjectIdentifier: NWConnection] = [:]
    private var inboundReadyConnections: Set<ObjectIdentifier> = []
    private var peerInboundConnections: [UUID: NWConnection] = [:]
    private var activationTask: Task<Void, Never>?
    private var localDeviceID: UUID?
    private let queue = DispatchQueue(label: "com.easystream.intercom", qos: .userInteractive)
    private var playbackEngine: AVAudioEngine?
    private var playbackNode: AVAudioPlayerNode?
    private var captureEngine: AVAudioEngine?
    private let sendFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: IntercomConstants.sampleRate,
        channels: 1,
        interleaved: false
    )

    public init() {}

    public var activeTargetPeer: TeamIntercomPeer? {
        if let targetPeerID, let peer = peers.first(where: { $0.id == targetPeerID }) {
            return peer
        }
        if peers.count == 1 {
            return peers.first
        }
        return nil
    }

    public func setTargetPeer(_ peerID: UUID?) {
        targetPeerID = peerID
        refreshStatusMessage()
    }

    public func start(identity: DeviceIdentity, role: AppRole) {
        if case .ready = state { return }
        if case .starting = state { return }
        localDeviceID = identity.deviceID
        needsLocalNetworkPermission = false
        state = .starting
        statusMessage = "Iniciando intercom…"

        startListener(identity: identity, role: role)
        startBrowser()
    }

    public func stop() {
        isTalking = false
        isActivating = false
        activationTask?.cancel()
        activationTask = nil
        stopCaptureEngine()
        browser?.cancel()
        browser = nil
        listener?.cancel()
        listener = nil
        for connection in connections.values {
            connection.cancel()
        }
        for connection in inboundConnections.values {
            connection.cancel()
        }
        connections.removeAll()
        inboundConnections.removeAll()
        inboundReadyConnections.removeAll()
        peerInboundConnections.removeAll()
        readyPeerConnections.removeAll()
        peers.removeAll()
        targetPeerID = nil
        teardownPlaybackEngine()
        needsLocalNetworkPermission = false
        state = .stopped
        statusMessage = "Intercom detenido"
    }

    public func toggleTalking() {
        if isTalking {
            endTalking()
        } else if !isActivating {
            beginTalking()
        }
    }

    public func beginTalking() {
        guard isEnabled, state == .ready else { return }
        guard !isTalking, !isActivating else { return }
        guard activeTargetPeer != nil else {
            statusMessage = peers.count > 1
                ? "Selecciona a quién hablar en el intercom"
                : "Sin destinatario en el canal"
            return
        }

        activationTask?.cancel()
        isActivating = true
        refreshStatusMessage()

        activationTask = Task {
            guard await ensureMicrophoneAccess() else {
                isActivating = false
                statusMessage = "Activa el micrófono en Ajustes para usar el intercom"
                return
            }
            guard !Task.isCancelled else {
                isActivating = false
                return
            }

            configureAudioSession(forPlaybackOnly: false)
            guard startCaptureEngine() else {
                isActivating = false
                statusMessage = "No se pudo activar el micrófono del intercom"
                return
            }
            guard !Task.isCancelled else {
                stopCaptureEngine()
                isActivating = false
                return
            }

            isActivating = false
            isTalking = true
            refreshStatusMessage()
        }
    }

    public func endTalking() {
        activationTask?.cancel()
        activationTask = nil
        isActivating = false
        guard isTalking else { return }
        isTalking = false
        stopCaptureEngine()
        refreshStatusMessage()
    }

    private func refreshStatusMessage() {
        if isActivating, let target = activeTargetPeer {
            statusMessage = "Activando intercom con \(target.displayName)…"
            return
        }
        if isTalking, let target = activeTargetPeer {
            if sendTargets().isEmpty {
                statusMessage = "Conectando con \(target.displayName)…"
            } else {
                statusMessage = "Transmitiendo a \(target.displayName)…"
            }
            return
        }
        if peers.isEmpty {
            statusMessage = "Intercom listo · sin equipo"
        } else if peers.count == 1, let peer = peers.first {
            statusMessage = "Intercom · \(peer.displayName)"
        } else if let target = activeTargetPeer {
            statusMessage = "Intercom · hablar con \(target.displayName)"
        } else {
            statusMessage = "Intercom · \(peers.count) en canal · elige destinatario"
        }
    }

    private func startListener(identity: DeviceIdentity, role: AppRole) {
        do {
            let parameters = makeIntercomParameters()
            let bonjourName = "ES-\(identity.deviceID.uuidString.prefix(8))"
            let service = NWListener.Service(
                name: bonjourName,
                type: BonjourServiceType.intercom.networkType,
                domain: NetworkConstants.serviceDomain,
                txtRecord: NWTXTRecord([
                    NetworkConstants.TXTKey.deviceID: identity.deviceID.uuidString,
                    NetworkConstants.TXTKey.displayName: identity.displayName,
                    NetworkConstants.TXTKey.role: role.rawValue,
                    NetworkConstants.TXTKey.protocolVersion: NetworkConstants.protocolVersion,
                    NetworkConstants.TXTKey.platform: identity.platform.rawValue,
                ])
            )

            let listener = try NWListener(service: service, using: parameters)

            listener.stateUpdateHandler = { [weak self] update in
                Task { @MainActor in
                    self?.handleListenerState(update)
                }
            }

            listener.newConnectionHandler = { [weak self] connection in
                Task { @MainActor in
                    self?.accept(connection: connection)
                }
            }

            listener.start(queue: queue)
            self.listener = listener
        } catch {
            state = .failed(error.localizedDescription)
            statusMessage = error.localizedDescription
        }
    }

    private func startBrowser() {
        let parameters = makeIntercomParameters()
        let descriptor = NWBrowser.Descriptor.bonjourWithTXTRecord(
            type: BonjourServiceType.intercom.networkType,
            domain: NetworkConstants.serviceDomain
        )
        let browser = NWBrowser(for: descriptor, using: parameters)

        browser.stateUpdateHandler = { [weak self] update in
            Task { @MainActor in
                self?.handleBrowserState(update)
            }
        }

        browser.browseResultsChangedHandler = { [weak self] results, _ in
            Task { @MainActor in
                self?.handleBrowseResults(results)
            }
        }

        browser.start(queue: queue)
        self.browser = browser
    }

    private func makeIntercomParameters() -> NWParameters {
        let parameters = NWParameters.udp
        parameters.allowLocalEndpointReuse = true
        parameters.includePeerToPeer = true
        parameters.serviceClass = .interactiveVoice
        return parameters
    }

    private func handleNetworkFailure(_ error: NWError, context: String) {
        if error.isEasyStreamLocalNetworkPermissionIssue {
            needsLocalNetworkPermission = true
            state = .failed(EasyStreamNetworkMessages.localNetworkPermissionRequired)
            statusMessage = EasyStreamNetworkMessages.localNetworkPermissionRequired
        } else {
            let message = "\(context): \(error.localizedDescription)"
            state = .failed(message)
            statusMessage = message
        }
    }

    private func handleListenerState(_ update: NWListener.State) {
        switch update {
        case .ready:
            if case .starting = state {
                state = .ready
                refreshStatusMessage()
            }
        case .failed(let error):
            handleNetworkFailure(error, context: "Intercom")
        case .cancelled:
            state = .stopped
        default:
            break
        }
    }

    private func handleBrowserState(_ update: NWBrowser.State) {
        switch update {
        case .failed(let error):
            handleNetworkFailure(error, context: "Búsqueda intercom")
        default:
            break
        }
    }

    private func handleBrowseResults(_ results: Set<NWBrowser.Result>) {
        var discoveredByID: [UUID: TeamIntercomPeer] = [:]

        for result in results {
            guard case .service(let name, _, _, _) = result.endpoint else { continue }
            guard let peer = peer(from: result) else { continue }
            if peer.id == localDeviceID { continue }

            discoveredByID[peer.id] = peer
            connectIfNeeded(to: result, peer: peer, fallbackName: name)
        }

        peers = discoveredByID.values.sorted {
            $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
        syncTargetPeer(with: peers)
        if !isTalking {
            refreshStatusMessage()
        }

        let activeIDs = Set(peers.map(\.id))
        for (id, connection) in connections where !activeIDs.contains(id) {
            connection.cancel()
            connections.removeValue(forKey: id)
            readyPeerConnections.remove(id)
        }
    }

    private func syncTargetPeer(with peers: [TeamIntercomPeer]) {
        if peers.count == 1 {
            targetPeerID = peers[0].id
        } else if let targetPeerID, !peers.contains(where: { $0.id == targetPeerID }) {
            self.targetPeerID = nil
        }
    }

    private func peer(from result: NWBrowser.Result) -> TeamIntercomPeer? {
        guard case .bonjour(let txtRecord) = result.metadata else { return nil }

        guard
            let deviceIDString = txtString(txtRecord, key: NetworkConstants.TXTKey.deviceID),
            let deviceID = UUID(uuidString: deviceIDString)
        else { return nil }

        let displayName = txtString(txtRecord, key: NetworkConstants.TXTKey.displayName) ?? "Equipo"
        return TeamIntercomPeer(id: deviceID, displayName: displayName)
    }

    private func txtString(_ record: NWTXTRecord, key: String) -> String? {
        guard let entry = record.getEntry(for: key) else { return nil }
        switch entry {
        case .string(let value):
            return value
        case .data(let data):
            return String(data: data, encoding: .utf8)
        case .empty, .none:
            return nil
        @unknown default:
            return nil
        }
    }

    private func connectIfNeeded(to result: NWBrowser.Result, peer: TeamIntercomPeer, fallbackName: String) {
        if let existing = connections[peer.id] {
            if readyPeerConnections.contains(peer.id) {
                return
            }
            existing.cancel()
            connections.removeValue(forKey: peer.id)
            readyPeerConnections.remove(peer.id)
        }

        let connection = NWConnection(to: result.endpoint, using: makeIntercomParameters())
        connection.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                guard let self else { return }
                switch state {
                case .ready:
                    self.readyPeerConnections.insert(peer.id)
                    if self.isTalking {
                        self.refreshStatusMessage()
                    }
                case .failed, .cancelled:
                    self.connections.removeValue(forKey: peer.id)
                    self.readyPeerConnections.remove(peer.id)
                default:
                    break
                }
            }
        }

        connection.start(queue: queue)
        connections[peer.id] = connection
        receive(on: connection, peerName: peer.displayName.isEmpty ? fallbackName : peer.displayName)
    }

    private func accept(connection: NWConnection) {
        let key = ObjectIdentifier(connection)
        guard inboundConnections[key] == nil else { return }

        inboundConnections[key] = connection
        connection.stateUpdateHandler = { [weak self] state in
            Task { @MainActor in
                guard let self else { return }
                switch state {
                case .ready:
                    self.inboundReadyConnections.insert(key)
                    if self.isTalking {
                        self.refreshStatusMessage()
                    }
                case .failed, .cancelled:
                    self.removeInboundConnection(key: key)
                default:
                    break
                }
            }
        }
        connection.start(queue: queue)
        receive(on: connection, peerName: "Equipo")
    }

    private func removeInboundConnection(key: ObjectIdentifier) {
        inboundReadyConnections.remove(key)
        inboundConnections.removeValue(forKey: key)
        if let peerID = peerInboundConnections.first(where: { ObjectIdentifier($0.value) == key })?.key {
            peerInboundConnections.removeValue(forKey: peerID)
        }
    }

    private func registerInboundSender(_ senderID: UUID, on connection: NWConnection) {
        let key = ObjectIdentifier(connection)
        peerInboundConnections[senderID] = connection
        inboundReadyConnections.insert(key)

        if !peers.contains(where: { $0.id == senderID }) {
            peers.append(TeamIntercomPeer(id: senderID, displayName: "Equipo"))
            peers.sort {
                $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
            syncTargetPeer(with: peers)
        }
    }

    private func decodeSenderID(from packet: Data) -> UUID? {
        guard packet.count >= IntercomConstants.senderIDByteCount else { return nil }
        let prefix = String(decoding: packet.prefix(IntercomConstants.senderIDByteCount), as: UTF8.self)
        guard !prefix.isEmpty else { return nil }

        var candidates = peers.map(\.id)
        if let targetPeerID, !candidates.contains(targetPeerID) {
            candidates.append(targetPeerID)
        }

        for peerID in candidates {
            let hex = peerID.uuidString.replacingOccurrences(of: "-", with: "")
            if hex.hasPrefix(prefix) {
                return peerID
            }
        }
        return nil
    }

    private func receive(on connection: NWConnection, peerName: String) {
        connection.receiveMessage { [weak self] content, _, _, _ in
            guard let self else { return }

            if let content, content.count > IntercomConstants.senderIDByteCount {
                let audioData = content.dropFirst(IntercomConstants.senderIDByteCount)
                Task { @MainActor in
                    if let senderID = self.decodeSenderID(from: content) {
                        self.registerInboundSender(senderID, on: connection)
                    }
                    self.playReceivedAudio(Data(audioData))
                }
            }

            Task { @MainActor in
                self.receive(on: connection, peerName: peerName)
            }
        }
    }

    private func sendAudioPCM(_ pcm: Data) {
        guard let localDeviceID else { return }

        var packet = Data()
        packet.append(contentsOf: localDeviceID.uuidString.replacingOccurrences(of: "-", with: "").prefix(IntercomConstants.senderIDByteCount).utf8)
        if packet.count < IntercomConstants.senderIDByteCount {
            packet.append(Data(repeating: 0, count: IntercomConstants.senderIDByteCount - packet.count))
        }
        packet.append(pcm)

        let targets = sendTargets()
        guard !targets.isEmpty else { return }

        for connection in targets {
            connection.send(content: packet, completion: .contentProcessed { _ in })
        }
    }

    private func sendTargets() -> [NWConnection] {
        var targets: [NWConnection] = []

        if let targetPeerID {
            if let outbound = connections[targetPeerID], readyPeerConnections.contains(targetPeerID) {
                targets.append(outbound)
            }
            if let inbound = peerInboundConnections[targetPeerID],
               inboundReadyConnections.contains(ObjectIdentifier(inbound)),
               !targets.contains(where: { $0 === inbound }) {
                targets.append(inbound)
            }
            if !targets.isEmpty {
                return targets
            }
        }

        if peers.count == 1, let peer = peers.first {
            if let outbound = connections[peer.id], readyPeerConnections.contains(peer.id) {
                targets.append(outbound)
            }
            if let inbound = peerInboundConnections[peer.id],
               inboundReadyConnections.contains(ObjectIdentifier(inbound)),
               !targets.contains(where: { $0 === inbound }) {
                targets.append(inbound)
            }
            if !targets.isEmpty {
                return targets
            }
        }

        for (peerID, connection) in connections where readyPeerConnections.contains(peerID) {
            targets.append(connection)
        }
        for (_, connection) in peerInboundConnections where inboundReadyConnections.contains(ObjectIdentifier(connection)) {
            if !targets.contains(where: { $0 === connection }) {
                targets.append(connection)
            }
        }
        return targets
    }

    private func configureAudioSession(forPlaybackOnly: Bool = false) {
#if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            if forPlaybackOnly {
                try session.setCategory(.playback, mode: .voiceChat, options: [.defaultToSpeaker, .mixWithOthers])
            } else {
                try session.setCategory(
                    .playAndRecord,
                    mode: .voiceChat,
                    options: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers]
                )
            }
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            EasyStreamLog.audio.error("Intercom audio session failed: \(error.localizedDescription, privacy: .public)")
        }
#endif
    }

    private func ensureMicrophoneAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .audio)
        default:
            return false
        }
    }

    private var playbackSessionConfigured = false

    private func setupPlaybackEngineIfNeeded() {
        guard playbackEngine == nil, let sendFormat, sendFormat.isValidIntercomFormat else { return }

        if !playbackSessionConfigured {
            configureAudioSession(forPlaybackOnly: true)
            playbackSessionConfigured = true
        }

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: sendFormat)
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: sendFormat)
        engine.prepare()

        do {
            try engine.start()
            player.play()
            playbackEngine = engine
            playbackNode = player
        } catch {
            EasyStreamLog.audio.error("Intercom playback engine failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func teardownPlaybackEngine() {
        playbackNode?.stop()
        playbackEngine?.stop()
        playbackNode = nil
        playbackEngine = nil
        playbackSessionConfigured = false
    }

    @discardableResult
    private func startCaptureEngine() -> Bool {
        stopCaptureEngine()
        guard let sendFormat else { return false }

        configureAudioSession(forPlaybackOnly: false)

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let mixer = engine.mainMixerNode

        // Wire the graph first — prepare() crashes if called with no valid nodes (common on macOS).
        engine.connect(inputNode, to: mixer, format: nil)
        engine.connect(mixer, to: engine.outputNode, format: nil)
        mixer.outputVolume = 0

        guard let tapFormat = nativeInputFormat(for: engine) else {
            EasyStreamLog.audio.error("Intercom capture: no valid hardware input format")
            return false
        }

        let converter = AVAudioConverter(from: tapFormat, to: sendFormat)

        inputNode.installTap(onBus: 0, bufferSize: 4_096, format: tapFormat) { [weak self] buffer, _ in
            guard let self, self.isTalking else { return }

            let pcmBuffer: AVAudioPCMBuffer?
            if let converter, needsConversion(from: tapFormat, to: sendFormat) {
                pcmBuffer = convert(buffer, with: converter, to: sendFormat)
            } else {
                pcmBuffer = buffer
            }

            guard let pcmBuffer, let pcm = encodePCM(from: pcmBuffer) else { return }

            Task { @MainActor in
                self.sendAudioPCM(pcm)
            }
        }

        engine.prepare()

        do {
            try engine.start()
            captureEngine = engine
            return true
        } catch {
            inputNode.removeTap(onBus: 0)
            engine.stop()
            EasyStreamLog.audio.error("Intercom capture engine failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    private func stopCaptureEngine() {
        guard let engine = captureEngine else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        captureEngine = nil
    }

    private func nativeInputFormat(for engine: AVAudioEngine) -> AVAudioFormat? {
        let inputNode = engine.inputNode
        let candidates = [
            inputNode.outputFormat(forBus: 0),
            inputNode.inputFormat(forBus: 0),
            engine.mainMixerNode.inputFormat(forBus: 0),
        ]
        for format in candidates where format.isValidIntercomFormat {
            return format
        }
        return nil
    }

    private func needsConversion(from input: AVAudioFormat, to output: AVAudioFormat) -> Bool {
        input.sampleRate != output.sampleRate || input.channelCount != output.channelCount
    }

    private func convert(_ buffer: AVAudioPCMBuffer, with converter: AVAudioConverter, to format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let frameCapacity = AVAudioFrameCount(
            Double(buffer.frameLength) * format.sampleRate / buffer.format.sampleRate
        ) + 1
        guard let converted = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return nil }

        var conversionError: NSError?
        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        converter.convert(to: converted, error: &conversionError, withInputFrom: inputBlock)
        guard conversionError == nil, converted.frameLength > 0 else { return nil }
        return converted
    }

    private func encodePCM(from buffer: AVAudioPCMBuffer) -> Data? {
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0, let channelData = buffer.floatChannelData else { return nil }

        let channelCount = Int(buffer.format.channelCount)
        var pcm = Data(capacity: frameCount * 2)

        for index in 0..<frameCount {
            var sample: Float = 0
            for channel in 0..<channelCount {
                sample += channelData[channel][index]
            }
            sample /= Float(channelCount)

            let clipped = max(-1, min(1, sample))
            let int16 = Int16(clipped * Float(Int16.max))
            var littleEndian = int16.littleEndian
            pcm.append(Data(bytes: &littleEndian, count: 2))
        }
        return pcm
    }

    private func playReceivedAudio(_ pcm: Data) {
        guard isEnabled else { return }

        let frameCount = pcm.count / MemoryLayout<Int16>.size
        guard frameCount > 0 else { return }

        setupPlaybackEngineIfNeeded()

        guard let playbackNode, let format = sendFormat else { return }

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount)) else { return }
        buffer.frameLength = AVAudioFrameCount(frameCount)

        pcm.withUnsafeBytes { rawBuffer in
            guard let int16Pointer = rawBuffer.bindMemory(to: Int16.self).baseAddress,
                  let floatData = buffer.floatChannelData?[0] else { return }
            for index in 0..<frameCount {
                floatData[index] = Float(int16Pointer[index]) / Float(Int16.max)
            }
        }

        if !playbackNode.isPlaying {
            playbackNode.play()
        }
        playbackNode.scheduleBuffer(buffer)
    }
}

private extension AVAudioFormat {
    var isValidIntercomFormat: Bool {
        sampleRate > 0 && channelCount > 0
    }
}
