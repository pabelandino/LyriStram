import Foundation
import EasyStreamCore

/// Applies remote camera imaging commands on the Camera Client.
public enum RemoteCameraCommandExecutor {
    public static func apply(_ command: RemoteCameraCommand, capture: CameraCaptureService) {
        switch command {
        case .setMuted:
            break
        case .setZoom(let factor):
            try? capture.setZoom(factor: factor)
        case .setExposureBias(let bias):
            try? capture.setExposureBias(bias)
        case .setWhiteBalance(let mode):
            if let option = WhiteBalanceModeOption(rawValue: mode) {
                try? capture.setWhiteBalance(option)
            }
        case .setLens(let lensRaw):
            if let lens = CameraLensKind(rawValue: lensRaw) {
                try? capture.switchLens(to: lens)
            }
        case .applySavedSettings(let settings):
            applySavedSettings(settings, capture: capture)
        case .setSwitcherAssignment:
            break
        case .reconnectStream:
            break
        }
    }

    public static func applySavedSettings(_ settings: RemoteCameraSettings, capture: CameraCaptureService) {
        if let lens = CameraLensKind(rawValue: settings.activeLens) {
            try? capture.switchLens(to: lens)
        }
        try? capture.setZoom(factor: settings.zoomFactor)
        try? capture.setExposureBias(settings.exposureBias)
        if let wb = WhiteBalanceModeOption(rawValue: settings.whiteBalance) {
            try? capture.setWhiteBalance(wb)
        }
    }

    public static func snapshot(from capture: CameraCaptureService, isMuted: Bool) -> RemoteCameraSettings {
        let imaging = capture.imagingState
        return RemoteCameraSettings(
            isMuted: isMuted,
            zoomFactor: imaging.zoomFactor,
            exposureBias: imaging.exposureBias,
            whiteBalance: imaging.whiteBalance.rawValue,
            activeLens: imaging.activeLens.rawValue
        )
    }
}
