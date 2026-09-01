import AVFoundation
import EasyStreamCore
#if os(iOS)
import UIKit
#endif
import CoreGraphics

/// LAN camera capture profile — tuned for low CPU and heat on iPhone.
public enum CameraStreamConfiguration {
#if os(iOS)
    public static let capturePreset: AVCaptureSession.Preset = .vga640x480
    public static let targetFrameRate: Int32 = CameraTransportDefaults.frameRate
    public static let webRTCWidth: Int32 = CameraTransportDefaults.width
    public static let webRTCHeight: Int32 = CameraTransportDefaults.height
    public static let webRTCMaxBitrateBps = CameraTransportDefaults.maxBitrateBps
    /// Max width for the on-device preview tile (stream uses `webRTCWidth` × `webRTCHeight`).
    public static let previewMaxWidth: CGFloat = 300
#else
    public static let capturePreset: AVCaptureSession.Preset = .hd1280x720
    public static let targetFrameRate: Int32 = CameraTransportDefaults.frameRate
    public static let webRTCWidth: Int32 = CameraTransportDefaults.width
    public static let webRTCHeight: Int32 = CameraTransportDefaults.height
    public static let webRTCMaxBitrateBps = CameraTransportDefaults.maxBitrateBps
    public static let previewMaxWidth: CGFloat = 640
#endif
}
