import Foundation
import AVFoundation
import CoreMedia
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
    private var isStreamingDeliveryEnabled = false
    private var activeLoadTier: CameraCaptureLoadTier?
#if os(iOS)
    private var orientationObserver: NSObjectProtocol?
    private var sceneActivationObserver: NSObjectProtocol?
    private var appActiveObserver: NSObjectProtocol?
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

    /// When false, `AVCaptureVideoDataOutput` delegate is detached — preview layer only (saves CPU while idle).
    public func setStreamingDeliveryEnabled(_ enabled: Bool) {
        sessionQueue.async {
            guard self.isStreamingDeliveryEnabled != enabled else { return }
            self.isStreamingDeliveryEnabled = enabled
            if enabled {
                self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            } else {
                self.videoOutput.setSampleBufferDelegate(nil, queue: nil)
            }
#if os(iOS)
            DispatchQueue.main.async {
                if enabled {
                    self.beginOrientationUpdatesIfNeeded()
                } else {
                    self.endOrientationUpdatesIfNeeded()
                }
            }
#endif
        }
    }

    /// Adjusts sensor preset + fps to match switcher role (major CPU/heat win on iPhone/iPad).
    public func applyCaptureLoadTier(_ tier: CameraCaptureLoadTier, streamSpec: BroadcastStreamSpec) {
        sessionQueue.async {
            let preset = tier.sessionPreset(for: streamSpec)
            if self.activeLoadTier != tier || self.session.sessionPreset != preset {
                self.activeLoadTier = tier
                self.session.beginConfiguration()
                if self.session.canSetSessionPreset(preset) {
                    self.session.sessionPreset = preset
                }
                self.session.commitConfiguration()
            }
            self.applyTargetFrameRate(streamSpec.frameRate)
        }
    }

    /// Adjusts capture frame rate to match the active transport profile (saves CPU when on standby).
    public func setTargetFrameRate(_ frameRate: Int32) async {
        await withCheckedContinuation { continuation in
            sessionQueue.async {
                self.applyTargetFrameRate(frameRate)
                continuation.resume()
            }
        }
    }

    private func applyTargetFrameRate(_ frameRate: Int32) {
        guard let device = videoInput?.device else { return }
        let fps = max(1, frameRate)
        do {
            try device.lockForConfiguration()
            device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: fps)
            device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: fps)
            device.unlockForConfiguration()
        } catch {
            return
        }
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
        if session.canSetSessionPreset(CameraStreamConfiguration.capturePreset) {
            session.sessionPreset = CameraStreamConfiguration.capturePreset
        } else {
            session.sessionPreset = .high
        }

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

#if os(iOS)
        try device.lockForConfiguration()
        let fps = CameraStreamConfiguration.targetFrameRate
        device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: fps)
        device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: fps)
        device.unlockForConfiguration()
#endif

        if session.outputs.isEmpty {
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
            ]
            videoOutput.alwaysDiscardsLateVideoFrames = true
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
            connection.applyVideoOrientation(CaptureVideoOrientation.resolvedOnMainThread())
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
        try device.lockForConfiguration()
        let fps = CameraStreamConfiguration.targetFrameRate
        device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: fps)
        device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: fps)
        device.unlockForConfiguration()
        videoOutput.connection(with: .video)?
            .applyVideoOrientation(CaptureVideoOrientation.resolvedOnMainThread())
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
        sceneActivationObserver = NotificationCenter.default.addObserver(
            forName: UIScene.didActivateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyVideoOrientation()
        }
        appActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyVideoOrientation()
        }
        applyVideoOrientation()
        scheduleOrientationRefreshBurst()
    }

    private func scheduleOrientationRefreshBurst() {
        for delay in [0.05, 0.2, 0.5, 1.0] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.applyVideoOrientation()
            }
        }
    }

    private func endOrientationUpdatesIfNeeded() {
        if let orientationObserver {
            NotificationCenter.default.removeObserver(orientationObserver)
            self.orientationObserver = nil
        }
        if let sceneActivationObserver {
            NotificationCenter.default.removeObserver(sceneActivationObserver)
            self.sceneActivationObserver = nil
        }
        if let appActiveObserver {
            NotificationCenter.default.removeObserver(appActiveObserver)
            self.appActiveObserver = nil
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
        guard isStreamingDeliveryEnabled else { return }
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
