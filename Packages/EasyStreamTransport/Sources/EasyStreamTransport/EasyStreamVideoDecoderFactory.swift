import Foundation
import WebRTC

/// WebRTC decoder factory that routes H.264 through VideoToolbox (`RTCVideoDecoderH264`).
///
/// On macOS Director, only H.264 is advertised so decoded frames stay as `RTCCVPixelBuffer` (NV12)
/// instead of software VP8/VP9 paths that deliver I420.
final class EasyStreamVideoDecoderFactory: NSObject, RTCVideoDecoderFactory {
    private let fallbackFactory = RTCDefaultVideoDecoderFactory()
    private let h264Only: Bool

    init(h264HardwareOnly: Bool) {
        self.h264Only = h264HardwareOnly
        super.init()
    }

    func supportedCodecs() -> [RTCVideoCodecInfo] {
        if h264Only {
            return RTCVideoDecoderH264.supportedCodecs()
        }
        return fallbackFactory.supportedCodecs()
    }

    func createDecoder(_ info: RTCVideoCodecInfo) -> RTCVideoDecoder? {
        if info.name.caseInsensitiveCompare(kRTCH264CodecName as String) == .orderedSame {
            return RTCVideoDecoderH264()
        }
        return fallbackFactory.createDecoder(info)
    }
}
