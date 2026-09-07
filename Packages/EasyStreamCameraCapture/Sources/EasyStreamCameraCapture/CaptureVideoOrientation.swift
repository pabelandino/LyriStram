import AVFoundation

#if os(iOS)
import UIKit

public enum CaptureVideoOrientation {
    /// Default camera framing — landscape 16:9 for director tiles and program.
    public static func preferredCameraLandscape() -> AVCaptureVideoOrientation {
        .landscapeRight
    }

    /// Preferred on the main thread; falls back to device orientation off-main.
    public static func current() -> AVCaptureVideoOrientation {
        preferredCameraLandscape()
    }

    /// Safe to call from capture session queues — hops to the main thread when needed.
    public static func resolvedOnMainThread() -> AVCaptureVideoOrientation {
        if Thread.isMainThread {
            return current()
        }
        return DispatchQueue.main.sync { current() }
    }

    public static func currentFromDevice() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        case .unknown, .faceUp, .faceDown:
            if let interface = interfaceOrientation() {
                return interface
            }
            return .portrait
        @unknown default:
            return interfaceOrientation() ?? .portrait
        }
    }

    private static func interfaceOrientation() -> AVCaptureVideoOrientation? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first(where: { $0.activationState == .foregroundActive })
            ?? scenes.first(where: { $0.activationState == .foregroundInactive })
            ?? scenes.first
        guard let scene else { return nil }

        switch scene.interfaceOrientation {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return nil
        }
    }
}

public extension AVCaptureConnection {
    func applyVideoOrientation(_ orientation: AVCaptureVideoOrientation) {
        guard isVideoOrientationSupported, videoOrientation != orientation else { return }
        videoOrientation = orientation
    }

    func applyCurrentVideoOrientationIfSupported() {
        applyVideoOrientation(CaptureVideoOrientation.current())
    }
}
#endif
