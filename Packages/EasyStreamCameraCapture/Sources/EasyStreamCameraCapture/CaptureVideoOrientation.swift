import AVFoundation

#if os(iOS)
import UIKit

public enum CaptureVideoOrientation {
    /// Preferred on the main thread; falls back to device orientation off-main.
    public static func current() -> AVCaptureVideoOrientation {
        if Thread.isMainThread, let interface = interfaceOrientation() {
            return interface
        }
        return currentFromDevice()
    }

    public static func currentFromDevice() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return .portrait
        }
    }

    private static func interfaceOrientation() -> AVCaptureVideoOrientation? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) else {
            return nil
        }

        switch windowScene.interfaceOrientation {
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
