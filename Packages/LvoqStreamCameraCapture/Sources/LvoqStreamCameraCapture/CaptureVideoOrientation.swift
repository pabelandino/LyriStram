import AVFoundation

#if os(iOS)
import UIKit

public enum CaptureVideoOrientation {
    /// Default camera framing — landscape 16:9 for director tiles and program.
    public static func preferredCameraLandscape() -> AVCaptureVideoOrientation {
        .landscapeRight
    }

    /// Matches the active landscape side (both orientations supported while locked to landscape).
    public static func current() -> AVCaptureVideoOrientation {
        if let interface = interfaceOrientation() {
            switch interface {
            case .landscapeLeft: return .landscapeLeft
            case .landscapeRight: return .landscapeRight
            default: break
            }
        }
        return landscapeFromDeviceOrientation() ?? preferredCameraLandscape()
    }

    /// Safe to call from capture session queues — hops to the main thread when needed.
    public static func resolvedOnMainThread() -> AVCaptureVideoOrientation {
        if Thread.isMainThread {
            return current()
        }
        return DispatchQueue.main.sync { current() }
    }

    public static func currentFromDevice() -> AVCaptureVideoOrientation {
        if let landscape = landscapeFromDeviceOrientation() {
            return landscape
        }
        if let interface = interfaceOrientation() {
            return interface
        }
        return .portrait
    }

    /// UIDevice landscape is inverted relative to `AVCaptureVideoOrientation` (Apple AVFoundation guidance).
    private static func landscapeFromDeviceOrientation() -> AVCaptureVideoOrientation? {
        switch UIDevice.current.orientation {
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return nil
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
