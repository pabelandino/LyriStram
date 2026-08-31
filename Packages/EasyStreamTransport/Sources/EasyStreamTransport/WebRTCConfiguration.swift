import Foundation
import WebRTC
import EasyStreamCore

enum WebRTCConfiguration {
    private static let initializeOnce: Void = {
        RTCInitializeSSL()
    }()

    static func factory() -> RTCPeerConnectionFactory {
        directorFactory()
    }

    /// Director factory with playout PCM tap for broadcast encoding.
    static func directorFactory() -> RTCPeerConnectionFactory {
        _ = initializeOnce
        let encoderFactory = RTCDefaultVideoEncoderFactory()
        let decoderFactory = RTCDefaultVideoDecoderFactory()
#if os(iOS)
        return RTCPeerConnectionFactory(
            encoderFactory: encoderFactory,
            decoderFactory: decoderFactory,
            audioDevice: ProgramAudioDeviceRegistry.sharedDevice
        )
#else
        return RTCPeerConnectionFactory(
            encoderFactory: encoderFactory,
            decoderFactory: decoderFactory
        )
#endif
    }

    /// Camera client factory with default audio capture device.
    static func cameraFactory() -> RTCPeerConnectionFactory {
        _ = initializeOnce
        let encoderFactory = RTCDefaultVideoEncoderFactory()
        let decoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(
            encoderFactory: encoderFactory,
            decoderFactory: decoderFactory
        )
    }

    static func peerConstraints() -> RTCMediaConstraints {
        RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: [
            "DtlsSrtpKeyAgreement": "true",
        ])
    }

    static func offerConstraints() -> RTCMediaConstraints {
        RTCMediaConstraints(mandatoryConstraints: [
            "OfferToReceiveAudio": "true",
            "OfferToReceiveVideo": "true",
        ], optionalConstraints: nil)
    }

    static func pcConfiguration() -> RTCConfiguration {
        let config = RTCConfiguration()
        config.iceServers = []
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        return config
    }
}

final class PeerConnectionDelegateBridge: NSObject, RTCPeerConnectionDelegate {
    var onIceCandidate: ((RTCIceCandidate) -> Void)?
    var onConnectionChange: ((RTCPeerConnectionState) -> Void)?
    var onTrack: ((RTCMediaStreamTrack) -> Void)?

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        stream.videoTracks.forEach { onTrack?($0) }
        stream.audioTracks.forEach { onTrack?($0) }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {}

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCPeerConnectionState) {
        onConnectionChange?(newState)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        onIceCandidate?(candidate)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}

    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd rtpReceiver: RTCRtpReceiver, streams mediaStreams: [RTCMediaStream]) {
        if let track = rtpReceiver.track {
            onTrack?(track)
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove rtpReceiver: RTCRtpReceiver) {}
}
