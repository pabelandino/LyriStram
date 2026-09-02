import Foundation
import WebRTC
import EasyStreamCore

/// Sends camera media to a Director over WebRTC after LAN signaling.
public actor CameraStreamClient {
    public enum Event: Sendable {
        case connectionState(StreamConnectionState)
        case localVideoTrackReady
        case failed(String)
    }

    private let sessionID = UUID()
    private let factory = WebRTCConfiguration.cameraFactory()
    /// Nonisolated so capture callbacks publish frames without awaiting this actor.
    public nonisolated let videoFramePublisher = WebRTCVideoFramePublisher()
    private var peerConnection: RTCPeerConnection?
    private let delegateBridge = PeerConnectionDelegateBridge()
    private var signaling: SignalingChannel?
    private var videoSource: RTCVideoSource?
    private var videoTrack: RTCVideoTrack?
    private var audioTrack: RTCAudioTrack?
    private var eventContinuation: AsyncStream<Event>.Continuation?
    private var hasCreatedOffer = false
    private var transportProfile = CameraTransportProfile.preview

    public init() {}

    public func events() -> AsyncStream<Event> {
        AsyncStream { continuation in
            eventContinuation = continuation
        }
    }

    public func attachSignaling(_ channel: SignalingChannel) {
        signaling = channel
    }

    public func setAudioMuted(_ muted: Bool) {
        audioTrack?.isEnabled = !muted
    }

    public var isAudioMuted: Bool {
        audioTrack?.isEnabled == false
    }

    public func prepareMediaTracks() {
        guard videoTrack == nil else { return }

        let videoSource = factory.videoSource()
        self.videoSource = videoSource
        videoSource.adaptOutputFormat(
            toWidth: transportProfile.width,
            height: transportProfile.height,
            fps: transportProfile.frameRate
        )
        videoFramePublisher.attach(to: videoSource)
        videoFramePublisher.updateTargetFrameRate(transportProfile.frameRate)
        videoTrack = factory.videoTrack(with: videoSource, trackId: "easystream-video")

        let audioSource = factory.audioSource(with: WebRTCConfiguration.peerConstraints())
        audioTrack = factory.audioTrack(with: audioSource, trackId: "easystream-audio")

        emit(.localVideoTrackReady)
    }

    public var localVideoTrack: RTCVideoTrack? { videoTrack }

    public func updateTransportProfile(_ profile: CameraTransportProfile) {
        guard transportProfile != profile else { return }
        transportProfile = profile

        videoSource?.adaptOutputFormat(
            toWidth: profile.width,
            height: profile.height,
            fps: profile.frameRate
        )
        videoFramePublisher.updateTargetFrameRate(profile.frameRate)
        applyOutboundVideoEncodingLimits(on: peerConnection)
    }

    public func publish(pixelBuffer: CVPixelBuffer, timestampNs: Int64, rotation: RTCVideoRotation = ._0) {
        videoFramePublisher.publish(pixelBuffer: pixelBuffer, timestampNs: timestampNs, rotation: rotation)
    }

    public func handleSignalingMessage(_ message: SignalingMessage) async throws {
        switch message {
        case .answer(let id, let sdp) where id == sessionID:
            try await setRemoteAnswer(sdp: sdp)
        case .ice(let id, let candidate, let sdpMid, let sdpMLineIndex) where id == sessionID:
            try await addIceCandidate(candidate: candidate, sdpMid: sdpMid, sdpMLineIndex: sdpMLineIndex)
        default:
            break
        }
    }

    public func startOffer() async throws {
        guard !hasCreatedOffer else { return }
        hasCreatedOffer = true
        emit(.connectionState(.signaling))

        let config = WebRTCConfiguration.pcConfiguration()
        let pc = factory.peerConnection(with: config, constraints: WebRTCConfiguration.peerConstraints(), delegate: delegateBridge)
        peerConnection = pc

        delegateBridge.onIceCandidate = { [weak self] candidate in
            Task { await self?.sendIceCandidate(candidate) }
        }

        delegateBridge.onConnectionChange = { [weak self] state in
            Task { await self?.handleConnectionState(state) }
        }

        guard let pc = peerConnection else { return }

        if let videoTrack {
            pc.add(videoTrack, streamIds: ["easystream"])
        }
        if let audioTrack {
            pc.add(audioTrack, streamIds: ["easystream"])
        }

        let offer = try await pc.offer(for: WebRTCConfiguration.offerConstraints())
        try await pc.setLocalDescription(offer)
        applyOutboundVideoEncodingLimits(on: pc)

        guard let signaling else { return }
        try await signaling.send(.offer(sessionID: sessionID, sdp: offer.sdp))
    }

    public func stop() {
        peerConnection?.close()
        peerConnection = nil
        hasCreatedOffer = false
        videoTrack = nil
        audioTrack = nil
        videoSource = nil
        videoFramePublisher.attach(to: nil)
        eventContinuation?.finish()
        eventContinuation = nil
    }

    /// Closes WebRTC only — keeps media tracks and signaling for a fast reconnect.
    public func resetPeerConnection() {
        peerConnection?.close()
        peerConnection = nil
        hasCreatedOffer = false
    }

    private func setRemoteAnswer(sdp: String) async throws {
        guard let peerConnection else { return }
        let description = RTCSessionDescription(type: .answer, sdp: sdp)
        try await peerConnection.setRemoteDescription(description)
    }

    private func addIceCandidate(candidate: String, sdpMid: String?, sdpMLineIndex: Int32?) async throws {
        guard let peerConnection else { return }
        let ice = RTCIceCandidate(sdp: candidate, sdpMLineIndex: sdpMLineIndex ?? 0, sdpMid: sdpMid)
        try await peerConnection.add(ice)
    }

    private func sendIceCandidate(_ candidate: RTCIceCandidate) async {
        guard let signaling else { return }
        try? await signaling.send(.ice(
            sessionID: sessionID,
            candidate: candidate.sdp,
            sdpMid: candidate.sdpMid,
            sdpMLineIndex: candidate.sdpMLineIndex
        ))
    }

    private func handleConnectionState(_ state: RTCPeerConnectionState) {
        switch state {
        case .connected:
            applyOutboundVideoEncodingLimits(on: peerConnection)
            emit(.connectionState(.connected))
        case .failed:
            emit(.failed("WebRTC connection failed"))
            emit(.connectionState(.failed))
        case .disconnected, .closed:
            emit(.connectionState(.disconnected))
        default:
            break
        }
    }

    private func applyOutboundVideoEncodingLimits(on pc: RTCPeerConnection?) {
        guard let pc else { return }
        guard let sender = pc.senders.first(where: { $0.track is RTCVideoTrack }) else { return }

        let params = sender.parameters
        guard !params.encodings.isEmpty else { return }

        var encoding = params.encodings[0]
        encoding.isActive = true
        encoding.maxFramerate = NSNumber(value: transportProfile.frameRate)
        encoding.maxBitrateBps = NSNumber(value: transportProfile.maxBitrateBps)
        encoding.minBitrateBps = NSNumber(value: transportProfile.minBitrateBps)
        encoding.scaleResolutionDownBy = NSNumber(value: 1.0)

        params.encodings = [encoding]
        sender.parameters = params
    }

    private func emit(_ event: Event) {
        eventContinuation?.yield(event)
    }
}

import CoreVideo

extension RTCPeerConnection {
    fileprivate func offer(for constraints: RTCMediaConstraints) async throws -> RTCSessionDescription {
        try await withCheckedThrowingContinuation { continuation in
            offer(for: constraints) { sdp, error in
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
