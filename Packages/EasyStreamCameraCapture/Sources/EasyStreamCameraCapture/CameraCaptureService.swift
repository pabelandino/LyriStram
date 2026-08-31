import Foundation
import AVFoundation
import EasyStreamCore
#if canImport(UIKit)
import UIKit
#endif

public enum CameraCaptureError: Error, Sendable {
    case permissionDenied
    case deviceUnavailable
    case configurationFailed
    case adjustmentFailed
}

/// AVFoundation capture pipeline with lens, zoom, exposure and white balance controls.
public final class CameraCaptureService: NSObject, @unchecked Sendable {
    public private(set) var permissionStatus: CameraPermissionStatus = .notDetermined
    public private(set) var imagingState = CameraImagingState()

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.easystream.capture.session")
    private let videoOutput = AVCaptureVideoDataOutput()
    private var videoInput: AVCaptureDeviceInput?
    private var activeLens: CameraLensKind = .wide
    private var isConfigured = false
#if os(iOS)
    private var orientationObserver: NSObjectProtocol?
#endif

    public var onVideoFrame: (@Sendable (CVPixelBuffer, CMTime) -> Void)?
    public var onImagingStateChanged: (@Sendable (CameraImagingState) -> Void)?

    public override init() {
        super.init()
    }

    public func requestPermission() async -> CameraPermissionStatus {
        let videoGranted: Bool
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            videoGranted = true
        } else if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            videoGranted = await AVCaptureDevice.requestAccess(for: .video)
        } else {
            videoGranted = false
        }

        let audioGranted: Bool
        if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            audioGranted = true
        } else if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined {
            audioGranted = await AVCaptureDevice.requestAccess(for: .audio)
        } else {
            audioGranted = true // video-only fallback; WebRTC may still capture mic
        }

        permissionStatus = videoGranted ? .authorized : .denied
        _ = audioGranted
        return permissionStatus
    }

    public func start() throws {
        guard permissionStatus == .authorized else {
            throw CameraCaptureError.permissionDenied
        }

        try sessionQueue.sync {
            if !isConfigured {
                try configureSession(lens: activeLens)
            }
            if !session.isRunning {
                session.startRunning()
            }
        }
#if os(iOS)
        beginOrientationUpdatesIfNeeded()
#endif
    }

    public func stop() {
#if os(iOS)
        endOrientationUpdatesIfNeeded()
#endif
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    public func makePreviewSession() -> AVCaptureSession {
        session
    }

    public func discoverAvailableLenses() -> [AvailableCameraLens] {
        var lenses: [AvailableCameraLens] = []

        for kind in [CameraLensKind.ultraWide, .wide, .telephoto] {
            if let device = captureDevice(for: kind), device.isConnected {
                lenses.append(AvailableCameraLens(kind: kind, localizedName: device.localizedName))
            }
        }

        if let front = captureDevice(for: .front), front.isConnected {
            lenses.append(AvailableCameraLens(kind: .front, localizedName: "Cámara frontal"))
        }

        if lenses.isEmpty, let fallback = captureDevice(for: .wide) {
            lenses.append(AvailableCameraLens(kind: .wide, localizedName: fallback.localizedName))
        }

        return lenses
    }

    public func switchLens(to kind: CameraLensKind) throws {
        try sessionQueue.sync {
            try reconfigureInput(lens: kind)
            publishImagingState()
        }
    }

    public func setZoom(factor: Double) throws {
        try sessionQueue.sync {
            guard let device = videoInput?.device else { throw CameraCaptureError.deviceUnavailable }
#if os(iOS)
            let clamped = min(max(factor, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)
            try device.lockForConfiguration()
            device.ramp(toVideoZoomFactor: clamped, withRate: 8)
            device.unlockForConfiguration()
            imagingState.zoomFactor = clamped
#else
            imagingState.zoomFactor = factor
#endif
            publishImagingState()
        }
    }

    public func setExposureBias(_ bias: Float) throws {
        try sessionQueue.sync {
            guard let device = videoInput?.device else { throw CameraCaptureError.deviceUnavailable }
#if os(iOS)
            let clamped = min(max(bias, device.minExposureTargetBias), device.maxExposureTargetBias)
            try device.lockForConfiguration()
            device.setExposureTargetBias(clamped, completionHandler: nil)
            device.unlockForConfiguration()
            imagingState.exposureBias = clamped
#else
            imagingState.exposureBias = bias
#endif
            publishImagingState()
        }
    }

    public func setWhiteBalance(_ mode: WhiteBalanceModeOption) throws {
        try sessionQueue.sync {
            guard let device = videoInput?.device else { throw CameraCaptureError.deviceUnavailable }
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            switch mode {
            case .auto:
                if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                    device.whiteBalanceMode = .continuousAutoWhiteBalance
                }
            case .locked:
                if device.isWhiteBalanceModeSupported(.locked) {
                    device.whiteBalanceMode = .locked
                }
            case .warm, .neutral, .cool:
#if os(iOS)
                if device.isWhiteBalanceModeSupported(.locked) {
                    let gains = whiteBalanceGains(for: mode, device: device)
                    let clamped = clampGains(gains, device: device)
                    device.setWhiteBalanceModeLocked(with: clamped, completionHandler: nil)
                }
#endif
            }

            imagingState.whiteBalance = mode
            publishImagingState()
        }
    }

    private func configureSession(lens: CameraLensKind) throws {
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080

        guard let device = captureDevice(for: lens) else {
            session.commitConfiguration()
            throw CameraCaptureError.deviceUnavailable
        }

        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else {
            session.commitConfiguration()
            throw CameraCaptureError.configurationFailed
        }
        session.addInput(input)
        videoInput = input
        activeLens = lens

        if session.outputs.isEmpty {
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            ]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            guard session.canAddOutput(videoOutput) else {
                session.commitConfiguration()
                throw CameraCaptureError.configurationFailed
            }
            session.addOutput(videoOutput)
        }

#if os(iOS)
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .off
            }
            connection.applyVideoOrientation(CaptureVideoOrientation.currentFromDevice())
        }
#endif

        session.commitConfiguration()
        isConfigured = true
        refreshImagingState(from: device)
    }

    private func reconfigureInput(lens: CameraLensKind) throws {
        guard let device = captureDevice(for: lens) else {
            throw CameraCaptureError.deviceUnavailable
        }

        let newInput = try AVCaptureDeviceInput(device: device)
        session.beginConfiguration()
        if let current = videoInput {
            session.removeInput(current)
        }
        guard session.canAddInput(newInput) else {
            session.commitConfiguration()
            throw CameraCaptureError.configurationFailed
        }
        session.addInput(newInput)
        videoInput = newInput
        activeLens = lens
#if os(iOS)
        videoOutput.connection(with: .video)?
            .applyVideoOrientation(CaptureVideoOrientation.currentFromDevice())
#endif
        session.commitConfiguration()
        refreshImagingState(from: device)
    }

#if os(iOS)
    private func beginOrientationUpdatesIfNeeded() {
        guard orientationObserver == nil else { return }
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        orientationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyVideoOrientation()
        }
        applyVideoOrientation()
    }

    private func endOrientationUpdatesIfNeeded() {
        if let orientationObserver {
            NotificationCenter.default.removeObserver(orientationObserver)
            self.orientationObserver = nil
        }
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    private func applyVideoOrientation() {
        let orientation = CaptureVideoOrientation.current()
        sessionQueue.async { [weak self] in
            self?.videoOutput.connection(with: .video)?.applyVideoOrientation(orientation)
        }
    }
#endif

    private func captureDevice(for kind: CameraLensKind) -> AVCaptureDevice? {
#if os(iOS)
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInUltraWideCamera,
            .builtInWideAngleCamera,
            .builtInTelephotoCamera,
            .builtInDualWideCamera,
            .builtInTripleCamera,
            .builtInDualCamera,
        ]
#else
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
        ]
#endif
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: kind.position
        )

        if kind == .front {
            return discovery.devices.first(where: { $0.position == .front })
        }

        switch kind {
#if os(iOS)
        case .ultraWide:
            return discovery.devices.first(where: { $0.deviceType == .builtInUltraWideCamera })
        case .telephoto:
            return discovery.devices.first(where: { $0.deviceType == .builtInTelephotoCamera })
        case .wide:
            return discovery.devices.first(where: { $0.deviceType == .builtInWideAngleCamera })
                ?? discovery.devices.first(where: { $0.position == .back })
        case .front:
            return discovery.devices.first(where: { $0.position == .front })
#else
        case .ultraWide, .wide, .telephoto:
            return discovery.devices.first(where: { $0.deviceType == .builtInWideAngleCamera })
                ?? discovery.devices.first(where: { $0.position == .back })
        case .front:
            return discovery.devices.first(where: { $0.position == .front })
#endif
        }
    }

    private func refreshImagingState(from device: AVCaptureDevice) {
#if os(iOS)
        imagingState = CameraImagingState(
            zoomFactor: device.videoZoomFactor,
            minZoomFactor: device.minAvailableVideoZoomFactor,
            maxZoomFactor: min(device.maxAvailableVideoZoomFactor, 10),
            exposureBias: device.exposureTargetBias,
            minExposureBias: device.minExposureTargetBias,
            maxExposureBias: device.maxExposureTargetBias,
            whiteBalance: imagingState.whiteBalance,
            activeLens: activeLens,
            availableLenses: discoverAvailableLenses()
        )
#else
        imagingState = CameraImagingState(
            whiteBalance: imagingState.whiteBalance,
            activeLens: activeLens,
            availableLenses: discoverAvailableLenses()
        )
#endif
        publishImagingState()
    }

    private func publishImagingState() {
        let state = imagingState
        DispatchQueue.main.async { [weak self] in
            self?.onImagingStateChanged?(state)
        }
    }

#if os(iOS)
    private func whiteBalanceGains(for mode: WhiteBalanceModeOption, device: AVCaptureDevice) -> AVCaptureDevice.WhiteBalanceGains {
        var gains = device.deviceWhiteBalanceGains
        switch mode {
        case .warm:
            gains.redGain = min(gains.redGain * 1.25, device.maxWhiteBalanceGain)
        case .cool:
            gains.blueGain = min(gains.blueGain * 1.25, device.maxWhiteBalanceGain)
        case .neutral:
            break
        default:
            break
        }
        return gains
    }

    private func clampGains(_ gains: AVCaptureDevice.WhiteBalanceGains, device: AVCaptureDevice) -> AVCaptureDevice.WhiteBalanceGains {
        var g = gains
        let maxGain = device.maxWhiteBalanceGain
        g.redGain = min(max(g.redGain, 1), maxGain)
        g.greenGain = min(max(g.greenGain, 1), maxGain)
        g.blueGain = min(max(g.blueGain, 1), maxGain)
        return g
    }
#endif
}

extension CameraCaptureService: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        onVideoFrame?(pixelBuffer, timestamp)
    }
}

public enum CameraPermissionStatus: Sendable, Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
}
