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
    private let photoOutput = AVCapturePhotoOutput()
    private var isPhotoOutputConfigured = false
    private var idlePhotoContinuation: CheckedContinuation<Data?, Never>?
    private var idlePhotoEncodeMaxWidth = 128
    private var idlePhotoEncodeQuality: CGFloat = 0.5
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

    /// When false, frames are not published to WebRTC — preview layer may still run.
    public func setStreamingDeliveryEnabled(_ enabled: Bool) {
        sessionQueue.async {
            guard self.isStreamingDeliveryEnabled != enabled else { return }
            self.isStreamingDeliveryEnabled = enabled
            self.syncVideoOutputDelegate()
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

    /// One-shot still for idle tile JPEG lane — no video delegate (matches baseline CPU while idle).
    public func captureIdleTileSnapshotJPEG(maxWidth: Int = 128, quality: CGFloat = 0.5) async -> Data? {
        await withCheckedContinuation { continuation in
            sessionQueue.async {
                guard self.session.isRunning else {
                    continuation.resume(returning: nil)
                    return
                }
                self.ensurePhotoOutputIfNeeded()
                guard self.isPhotoOutputConfigured else {
                    continuation.resume(returning: nil)
                    return
                }
                if let pending = self.idlePhotoContinuation {
                    self.idlePhotoContinuation = nil
                    pending.resume(returning: nil)
                }
                self.idlePhotoContinuation = continuation
                self.idlePhotoEncodeMaxWidth = maxWidth
                self.idlePhotoEncodeQuality = quality
#if os(iOS)
                self.photoOutput.connection(with: .video)?
                    .applyVideoOrientation(CaptureVideoOrientation.resolvedOnMainThread())
#endif

                let settings: AVCapturePhotoSettings
                if self.photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
                    settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                } else {
                    settings = AVCapturePhotoSettings()
                }
                settings.photoQualityPrioritization = .speed
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }

    private func syncVideoOutputDelegate() {
        if isStreamingDeliveryEnabled {
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        } else {
            videoOutput.setSampleBufferDelegate(nil, queue: nil)
        }
    }

    private func ensurePhotoOutputIfNeeded() {
        guard !isPhotoOutputConfigured else { return }
        session.beginConfiguration()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            isPhotoOutputConfigured = true
#if os(iOS)
            photoOutput.connection(with: .video)?
                .applyVideoOrientation(CaptureVideoOrientation.resolvedOnMainThread())
#endif
        }
        session.commitConfiguration()
    }

    private func finishIdlePhotoCapture(with data: Data?) {
        let continuation = idlePhotoContinuation
        idlePhotoContinuation = nil
        continuation?.resume(returning: data)
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
        applyTargetFrameRate(frameRate, to: device)
    }

    /// Clamps to `videoSupportedFrameRateRanges` — raw 8 fps on CIF/idle preset traps in AVFoundation.
    private func applyTargetFrameRate(_ frameRate: Int32, to device: AVCaptureDevice) {
        guard device.isConnected else { return }
        let clamped = Self.clampedFrameRate(Double(max(1, frameRate)), for: device)
        let timescale = CMTimeScale(max(1, min(120, Int32(clamped.rounded()))))
        let duration = CMTime(value: 1, timescale: timescale)

        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            guard Self.format(device.activeFormat, supportsFrameDuration: duration) else { return }
            device.activeVideoMinFrameDuration = duration
            device.activeVideoMaxFrameDuration = duration
        } catch {
            return
        }
    }

    private static func clampedFrameRate(_ requested: Double, for device: AVCaptureDevice) -> Double {
        let ranges = device.activeFormat.videoSupportedFrameRateRanges
        guard !ranges.isEmpty else { return min(requested, 30) }
        if ranges.contains(where: { requested >= $0.minFrameRate && requested <= $0.maxFrameRate }) {
            return requested
        }
        var best = ranges[0].minFrameRate
        var bestDistance = abs(requested - best)
        for range in ranges {
            let candidate = min(max(requested, range.minFrameRate), range.maxFrameRate)
            let distance = abs(requested - candidate)
            if distance < bestDistance {
                bestDistance = distance
                best = candidate
            }
        }
        return best
    }

    private static func format(_ format: AVCaptureDevice.Format, supportsFrameDuration duration: CMTime) -> Bool {
        let fps = Double(duration.timescale) / Double(max(1, duration.value))
        return format.videoSupportedFrameRateRanges.contains {
            fps >= $0.minFrameRate && fps <= $0.maxFrameRate
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
        applyTargetFrameRate(CameraStreamConfiguration.targetFrameRate, to: device)
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
        applyTargetFrameRate(CameraStreamConfiguration.targetFrameRate, to: device)
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
            guard let self else { return }
            self.videoOutput.connection(with: .video)?.applyVideoOrientation(orientation)
            self.photoOutput.connection(with: .video)?.applyVideoOrientation(orientation)
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

extension CameraCaptureService: AVCapturePhotoCaptureDelegate {
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil else {
            finishIdlePhotoCapture(with: nil)
            return
        }
        guard let rawJPEG = photo.fileDataRepresentation() else {
            finishIdlePhotoCapture(with: nil)
            return
        }
        let jpeg = TileSnapshotJPEGEncoder.recompress(
            jpegData: rawJPEG,
            maxWidth: idlePhotoEncodeMaxWidth,
            quality: idlePhotoEncodeQuality
        ) ?? rawJPEG
        finishIdlePhotoCapture(with: jpeg)
    }
}

public enum CameraPermissionStatus: Sendable, Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
}
