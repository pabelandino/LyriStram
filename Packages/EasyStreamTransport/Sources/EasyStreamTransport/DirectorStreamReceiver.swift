import Foundation
import WebRTC
import EasyStreamCore

/// Receives camera media from multiple Camera Clients on the Director over WebRTC.
public actor DirectorStreamReceiver {
    public enum Event {
        case sourceConnected(CameraSourceID, displayName: String)
        case sourceDisconnected(CameraSourceID)
        case sourceVideoTrack(CameraSourceID, RTCVideoTrack, displayName: String)
        case sourceAudioTrack(CameraSourceID, RTCAudioTrack, displayName: String)
        case sourceConnectionState(CameraSourceID, StreamConnectionState)
        case sourceSettingsUpdated(CameraSourceID, RemoteCameraSettings)
        case failed(String)
    }

    private let factory = WebRTCConfiguration.directorFactory()
    private var sessions: [UUID: SessionContext] = [:]
    private var sessionIDBySource: [CameraSourceID: UUID] = [:]
    private var pendingHello: [UUID: (deviceID: UUID, displayName: String)] = [:]
    private var pendingRemoteNames: [UUID: String] = [:]
    private var eventContinuation: AsyncStream<Event>.Continuation?

    private struct SessionContext {
        let sessionID: UUID
        let sourceID: CameraSourceID
        let remoteDisplayName: String
        let peerConnection: RTCPeerConnection
        let signaling: SignalingChannel
    }

    public init() {}

    public func events() -> AsyncStream<Event> {
        AsyncStream { continuation in
            eventContinuation = continuation
        }
    }

    public func handleIncomingConnection(_ connection: NWConnection) {
        let channel = SignalingChannel(connection: connection)
        Task {
            await observeSignaling(channel)
        }
    }

    public func stop() {
        for session in sessions.values {
            session.peerConnection.close()
            Task { await session.signaling.stop() }
        }
        sessions.removeAll()
        sessionIDBySource.removeAll()
        pendingHello.removeAll()
        pendingRemoteNames.removeAll()
        eventContinuation?.finish()
        eventContinuation = nil
    }

    public func sendControl(to sourceID: CameraSourceID, command: RemoteCameraCommand) async throws {
        guard let sessionID = sessionIDBySource[sourceID],
              let context = sessions[sessionID] else {
            throw DirectorStreamError.sourceNotConnected
        }
        try await context.signaling.send(.control(command))
    }

    /// Tears down WebRTC for a source and asks the camera to negotiate a new stream.
    public func prepareReconnect(for sourceID: CameraSourceID) async throws {
        guard let sessionID = sessionIDBySource[sourceID],
              let context = sessions[sessionID] else {
            throw DirectorStreamError.sourceNotConnected
        }
        context.peerConnection.close()
        sessions.removeValue(forKey: sessionID)
        sessionIDBySource.removeValue(forKey: sourceID)
        emit(.sourceConnectionState(sourceID, .connecting))
        try await context.signaling.send(.control(.reconnectStream))
    }

    private func observeSignaling(_ channel: SignalingChannel) {
        Task {
            for await event in await channel.events() {
                switch event {
                case .connected:
                    break
                case .message(let message):
                    await handleSignalingMessage(message, channel: channel)
                case .disconnected:
                    await handleChannelDisconnected(channel)
                case .failed(let error):
                    emit(.failed(error))
                }
            }
        }
    }

    private func handleSignalingMessage(_ message: SignalingMessage, channel: SignalingChannel) async {
        switch message {
        case .hello(let deviceID, let displayName, _):
            EasyStreamLog.transport.info("Signaling hello from \(displayName, privacy: .public)")
            let sourceID = CameraSourceID(deviceID)
            if let existingSessionID = sessionIDBySource[sourceID],
               let existing = sessions[existingSessionID],
               existing.signaling.id != channel.id {
                existing.peerConnection.close()
                sessions.removeValue(forKey: existingSessionID)
                sessionIDBySource.removeValue(forKey: sourceID)
                pendingHello.removeValue(forKey: existing.signaling.id)
                Task { await existing.signaling.stop() }
                emit(.sourceConnectionState(sourceID, .connecting))
            }
            pendingHello[channel.id] = (deviceID, displayName)
        case .offer(let sessionID, let sdp):
            let hello = pendingHello[channel.id]
            let deviceID = hello?.deviceID ?? UUID()
            let remoteName = hello?.displayName ?? "Cámara"
            let sourceID = CameraSourceID(deviceID)
            await handleOffer(
                sessionID: sessionID,
                sourceID: sourceID,
                sdp: sdp,
                channel: channel,
                remoteName: remoteName
            )
        case .ice(let sessionID, let candidate, let sdpMid, let sdpMLineIndex):
            await addIceCandidate(sessionID: sessionID, candidate: candidate, sdpMid: sdpMid, sdpMLineIndex: sdpMLineIndex)
        case .settingsState(let deviceID, let settings):
            emit(.sourceSettingsUpdated(CameraSourceID(deviceID), settings))
        default:
            break
        }
    }

    private func handleOffer(
        sessionID: UUID,
        sourceID: CameraSourceID,
        sdp: String,
        channel: SignalingChannel,
        remoteName: String
    ) async {
        if let existingSessionID = sessionIDBySource[sourceID] {
            if let existing = sessions[existingSessionID] {
                existing.peerConnection.close()
            }
            sessions.removeValue(forKey: existingSessionID)
            sessionIDBySource.removeValue(forKey: sourceID)
        }

        emit(.sourceConnectionState(sourceID, .signaling))

        let delegateBridge = PeerConnectionDelegateBridge()
        let config = WebRTCConfiguration.pcConfiguration()
        guard let pc = factory.peerConnection(with: config, constraints: WebRTCConfiguration.peerConstraints(), delegate: delegateBridge) else {
            emit(.failed("Failed to create peer connection"))
            return
        }

        let context = SessionContext(
            sessionID: sessionID,
            sourceID: sourceID,
            remoteDisplayName: remoteName,
            peerConnection: pc,
            signaling: channel
        )
        sessions[sessionID] = context
        sessionIDBySource[sourceID] = sessionID

        emit(.sourceConnected(sourceID, displayName: remoteName))

        // Push saved settings to camera when it connects.
        Task {
            let saved = await CameraSettingsStore.shared.settings(for: sourceID)
            try? await channel.send(.control(.applySavedSettings(saved)))
        }

        delegateBridge.onIceCandidate = { candidate in
            Task {
                try? await channel.send(.ice(
                    sessionID: sessionID,
                    candidate: candidate.sdp,
                    sdpMid: candidate.sdpMid,
                    sdpMLineIndex: candidate.sdpMLineIndex
                ))
            }
        }

        delegateBridge.onTrack = { [weak self] track in
            Task { await self?.handleRemoteTrack(track, sourceID: sourceID, remoteName: remoteName) }
        }

        delegateBridge.onConnectionChange = { [weak self] state in
            Task { await self?.handleConnectionState(state, sourceID: sourceID) }
        }

        do {
            let remote = RTCSessionDescription(type: .offer, sdp: sdp)
            try await pc.setRemoteDescription(remote)
            EasyStreamWebRTCH264Preferences.preferH264Video(on: pc, factory: factory, receiver: true)
            let answer = try await pc.answer(for: WebRTCConfiguration.offerConstraints())
            try await pc.setLocalDescription(answer)
            try await channel.send(.answer(sessionID: sessionID, sdp: answer.sdp))
        } catch {
            emit(.failed(error.localizedDescription))
            emit(.sourceConnectionState(sourceID, .failed))
        }
    }

    private func addIceCandidate(sessionID: UUID, candidate: String, sdpMid: String?, sdpMLineIndex: Int32?) async {
        guard let context = sessions[sessionID] else { return }
        let ice = RTCIceCandidate(sdp: candidate, sdpMLineIndex: sdpMLineIndex ?? 0, sdpMid: sdpMid)
        try? await context.peerConnection.add(ice)
    }

    private func handleRemoteTrack(_ track: RTCMediaStreamTrack, sourceID: CameraSourceID, remoteName: String) {
        if let videoTrack = track as? RTCVideoTrack {
            emit(.sourceVideoTrack(sourceID, videoTrack, displayName: remoteName))
        } else if let audioTrack = track as? RTCAudioTrack {
            emit(.sourceAudioTrack(sourceID, audioTrack, displayName: remoteName))
        }
    }

    private func handleConnectionState(_ state: RTCPeerConnectionState, sourceID: CameraSourceID) {
        switch state {
        case .connected:
            emit(.sourceConnectionState(sourceID, .connected))
        case .failed:
            emit(.sourceConnectionState(sourceID, .failed))
        case .disconnected, .closed:
            emit(.sourceConnectionState(sourceID, .disconnected))
        default:
            break
        }
    }

    private func handleChannelDisconnected(_ channel: SignalingChannel) async {
        guard let session = sessions.first(where: { $0.value.signaling.id == channel.id }) else { return }
        let sourceID = session.value.sourceID
        sessions.removeValue(forKey: session.key)
        sessionIDBySource.removeValue(forKey: sourceID)
        pendingHello.removeValue(forKey: channel.id)
        session.value.peerConnection.close()
        emit(.sourceDisconnected(sourceID))
        emit(.sourceConnectionState(sourceID, .disconnected))
    }

    private func emit(_ event: Event) {
        eventContinuation?.yield(event)
    }
}

public enum DirectorStreamError: Error, Sendable {
    case sourceNotConnected
}

import Network

extension RTCPeerConnection {
    fileprivate func answer(for constraints: RTCMediaConstraints) async throws -> RTCSessionDescription {
        try await withCheckedThrowingContinuation { continuation in
            answer(for: constraints) { sdp, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let sdp {
                    continuation.resume(returning: sdp)
                } else {
                    continuation.resume(throwing: NSError(domain: "EasyStreamTransport", code: -1))
                }
            }
        }
    }

    fileprivate func setLocalDescription(_ sdp: RTCSessionDescription) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            setLocalDescription(sdp) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    fileprivate func setRemoteDescription(_ sdp: RTCSessionDescription) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            setRemoteDescription(sdp) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    fileprivate func add(_ candidate: RTCIceCandidate) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            add(candidate) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
