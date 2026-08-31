import Foundation
import AVFoundation

public enum CameraLensKind: String, Sendable, CaseIterable, Identifiable {
    case ultraWide
    case wide
    case telephoto
    case front

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .ultraWide: "Ultra gran angular"
        case .wide: "Gran angular"
        case .telephoto: "Teleobjetivo"
        case .front: "Frontal"
        }
    }

    var deviceType: AVCaptureDevice.DeviceType {
#if os(iOS)
        switch self {
        case .ultraWide: .builtInUltraWideCamera
        case .wide: .builtInWideAngleCamera
        case .telephoto: .builtInTelephotoCamera
        case .front: .builtInWideAngleCamera
        }
#else
        .builtInWideAngleCamera
#endif
    }

    var position: AVCaptureDevice.Position {
        self == .front ? .front : .back
    }
}

public enum WhiteBalanceModeOption: String, Sendable, CaseIterable, Identifiable {
    case auto
    case locked
    case warm
    case neutral
    case cool

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .auto: "Automático"
        case .locked: "Bloqueado"
        case .warm: "Cálido"
        case .neutral: "Neutro"
        case .cool: "Frío"
        }
    }
}

public struct AvailableCameraLens: Sendable, Identifiable, Equatable {
    public let id: String
    public let kind: CameraLensKind
    public let localizedName: String

    public init(kind: CameraLensKind, localizedName: String) {
        self.id = kind.rawValue
        self.kind = kind
        self.localizedName = localizedName
    }
}

public struct CameraImagingState: Sendable, Equatable {
    public var zoomFactor: Double
    public var minZoomFactor: Double
    public var maxZoomFactor: Double
    public var exposureBias: Float
    public var minExposureBias: Float
    public var maxExposureBias: Float
    public var whiteBalance: WhiteBalanceModeOption
    public var activeLens: CameraLensKind
    public var availableLenses: [AvailableCameraLens]

    public init(
        zoomFactor: Double = 1,
        minZoomFactor: Double = 1,
        maxZoomFactor: Double = 1,
        exposureBias: Float = 0,
        minExposureBias: Float = -2,
        maxExposureBias: Float = 2,
        whiteBalance: WhiteBalanceModeOption = .auto,
        activeLens: CameraLensKind = .wide,
        availableLenses: [AvailableCameraLens] = []
    ) {
        self.zoomFactor = zoomFactor
        self.minZoomFactor = minZoomFactor
        self.maxZoomFactor = maxZoomFactor
        self.exposureBias = exposureBias
        self.minExposureBias = minExposureBias
        self.maxExposureBias = maxExposureBias
        self.whiteBalance = whiteBalance
        self.activeLens = activeLens
        self.availableLenses = availableLenses
    }
}
