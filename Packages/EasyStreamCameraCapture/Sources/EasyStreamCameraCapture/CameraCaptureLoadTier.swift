import AVFoundation
import EasyStreamCore

/// Sensor load tier — capture resolution/fps aligned with LAN transport profile.
public enum CameraCaptureLoadTier: Sendable, Equatable {
    /// Connected but not streaming to director — preview layer only.
    case idle
    /// Preview tile on director — moderate sensor load.
    case preview
    /// On program — capture matched to PROG preset (not full sensor).
    case program
}

extension CameraCaptureLoadTier {
    func sessionPreset(for streamSpec: BroadcastStreamSpec) -> AVCaptureSession.Preset {
        switch self {
        case .idle:
            return .lowestStablePreset
        case .preview, .program:
            return AVCaptureSession.Preset.closest(to: streamSpec)
        }
    }
}

private extension AVCaptureSession.Preset {
    static var lowestStablePreset: AVCaptureSession.Preset {
#if os(iOS)
        .cif352x288
#else
        .vga640x480
#endif
    }

    static func closest(to spec: BroadcastStreamSpec) -> AVCaptureSession.Preset {
        let maxEdge = max(spec.width, spec.height)
        let candidates: [(threshold: Int32, preset: AVCaptureSession.Preset)] = [
            (360, .vga640x480),
            (540, .vga640x480),
            (720, .hd1280x720),
            (1_080, .hd1920x1080),
        ]
        for candidate in candidates where maxEdge <= candidate.threshold {
            return candidate.preset
        }
        return .hd1920x1080
    }
}
