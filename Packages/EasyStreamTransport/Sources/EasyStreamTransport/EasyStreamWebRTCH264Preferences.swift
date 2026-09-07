import EasyStreamCore
import Foundation
import WebRTC

enum EasyStreamWebRTCH264Preferences {
    static func preferredH264EncoderCodec() -> RTCVideoCodecInfo? {
        RTCDefaultVideoEncoderFactory.supportedCodecs().first {
            $0.name.caseInsensitiveCompare(kRTCH264CodecName as String) == .orderedSame
        }
    }

    static func h264VideoCapabilities(
        from factory: RTCPeerConnectionFactory,
        receiver: Bool
    ) -> [RTCRtpCodecCapability] {
        let capabilities: RTCRtpCapabilities
        if receiver {
            capabilities = factory.rtpReceiverCapabilities(forKind: kRTCMediaStreamTrackKindVideo)
        } else {
            capabilities = factory.rtpSenderCapabilities(forKind: kRTCMediaStreamTrackKindVideo)
        }
        return capabilities.codecs.filter {
            $0.name.caseInsensitiveCompare(kRTCH264CodecName as String) == .orderedSame
        }
    }

    /// Restricts video transceivers to H.264 so the remote side negotiates VideoToolbox NV12 output.
    static func preferH264Video(
        on peerConnection: RTCPeerConnection,
        factory: RTCPeerConnectionFactory,
        receiver: Bool
    ) {
        let codecs = h264VideoCapabilities(from: factory, receiver: receiver)
        guard !codecs.isEmpty else {
            EasyStreamLog.transport.warning("H.264 codec capabilities unavailable for WebRTC preference")
            return
        }

        for transceiver in peerConnection.transceivers where transceiver.mediaType == .video {
            transceiver.setCodecPreferences(codecs)
        }
    }
}
