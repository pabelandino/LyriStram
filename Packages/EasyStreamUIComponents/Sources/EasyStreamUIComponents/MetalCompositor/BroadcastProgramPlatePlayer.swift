import AVFoundation
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import EasyStreamCore

/// Decodes one library image or video into the program plate. The camera bus is not re-encoded.
public final class BroadcastProgramPlatePlayer: @unchecked Sendable {
    public static let shared = BroadcastProgramPlatePlayer()

    public var onPlaybackEnded: (@Sendable () -> Void)?
    public var onFailure: (@Sendable (String) -> Void)?

    private let plateWidth = 1280
    private let plateHeight = 720
    private let context = CIContext(options: [.cacheIntermediates: false])
    private let stateLock = NSLock()
    private let pumpQueue = DispatchQueue(label: "easystream.program-plate", qos: .userInitiated)
    private var player: AVPlayer?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var endObserver: NSObjectProtocol?
    private var pump: DispatchSourceTimer?
    private var presentedURL: URL?
    private var playbackTransform = CGAffineTransform.identity
    private var playbackRunning = false

    private init() {}

    public func present(url: URL, kind: BroadcastResourceKind) {
        switch kind {
        case .image:
            presentImage(url: url)
        case .video:
            presentVideo(url: url)
        case .widget:
            clear()
        }
    }

    public func clear() {
        setPresentedURL(nil)
        setPlaybackRunning(false)
        pumpQueue.async { [weak self] in
            self?.stopVideoLocked()
        }
        BroadcastProgramPlateBus.shared.setFrame(nil, animating: false)
        publish(isVideo: false, isPlaying: false)
    }

    public func resume() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let player = self.player else { return }
            let begin = { [weak self] in
                guard let self else { return }
                self.setPlaybackRunning(true)
                player.play()
                BroadcastProgramPlateBus.shared.setVideoAnimating(true)
                self.publish(isVideo: true, isPlaying: true)
            }
            if let item = player.currentItem {
                let duration = item.duration
                if duration.isNumeric, item.currentTime() >= duration - CMTime(value: 1, timescale: 30) {
                    player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                        DispatchQueue.main.async(execute: begin)
                    }
                    return
                }
            }
            begin()
        }
    }

    public func pause() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.setPlaybackRunning(false)
            self.player?.pause()
            BroadcastProgramPlateBus.shared.setVideoAnimating(false)
            self.publish(isVideo: true, isPlaying: false)
        }
    }

    /// Pauses and returns to the first frame.
    public func stopAtStart() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let player = self.player else { return }
            let url = self.currentURL()
            self.setPlaybackRunning(false)
            player.pause()
            player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
                guard let self, let url else { return }
                self.pumpQueue.async {
                    self.pullVideoFrame(url: url, force: true)
                }
            }
            BroadcastProgramPlateBus.shared.setVideoAnimating(false)
            self.publish(isVideo: true, isPlaying: false)
        }
    }

    private func presentImage(url: URL) {
        pumpQueue.async { [weak self] in
            self?.stopVideoLocked()
        }
        setPresentedURL(url)
        publish(isVideo: false, isPlaying: false)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            guard let image = Self.loadImage(at: url), let frame = self.coverBitmap(from: image) else {
                self.onFailure?("No se pudo mostrar la imagen")
                return
            }
            guard self.currentURL() == url else { return }
            BroadcastProgramPlateBus.shared.setFrame(frame, animating: false)
        }
    }

    private func presentVideo(url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.pumpQueue.sync {
                self.stopVideoLocked()
            }
            self.setPresentedURL(url)
            self.setPlaybackTransform(.identity)
            self.setPlaybackRunning(false)
            Task { [weak self] in
                let transform = await Self.loadPreferredTransform(for: url)
                await MainActor.run { [weak self] in
                    guard let self, self.currentURL() == url else { return }
                    self.setPlaybackTransform(transform)
                    self.startVideoItem(url: url)
                }
            }
        }
    }

    private func startVideoItem(url: URL) {
        let item = AVPlayerItem(url: url)
        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true
        ])
        item.add(output)
        let player = AVPlayer(playerItem: item)
        player.actionAtItemEnd = .pause
        self.player = player
        self.setVideoOutput(output)
        self.observeEnd(of: item, url: url)
        self.setPlaybackRunning(true)
        player.play()
        self.publish(isVideo: true, isPlaying: true)
        self.startPump(url: url)
    }

    private static func loadPreferredTransform(for url: URL) async -> CGAffineTransform {
        let asset = AVURLAsset(url: url)
        do {
            let tracks = try await asset.loadTracks(withMediaType: .video)
            guard let track = tracks.first else { return .identity }
            return try await track.load(.preferredTransform)
        } catch {
            return .identity
        }
    }

    private func observeEnd(of item: AVPlayerItem, url: URL) {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self, self.currentURL() == url else { return }
            self.setPlaybackRunning(false)
            BroadcastProgramPlateBus.shared.setVideoAnimating(false)
            self.publish(isVideo: true, isPlaying: false)
            self.onPlaybackEnded?()
        }
    }

    private func startPump(url: URL) {
        pumpQueue.async { [weak self] in
            guard let self else { return }
            self.pump?.cancel()
            let timer = DispatchSource.makeTimerSource(queue: self.pumpQueue)
            timer.schedule(deadline: .now(), repeating: .milliseconds(16))
            timer.setEventHandler { [weak self] in
                self?.pullVideoFrame(url: url)
            }
            self.pump = timer
            timer.resume()
        }
    }

    private func pullVideoFrame(url: URL, force: Bool = false) {
        guard currentURL() == url, let output = currentVideoOutput() else { return }
        let itemTime = output.itemTime(forHostTime: CACurrentMediaTime())
        let time = itemTime.isValid ? itemTime : .zero
        if !force, !output.hasNewPixelBuffer(forItemTime: time) { return }
        guard let pixelBuffer = output.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else { return }
        guard currentURL() == url else { return }
        BroadcastProgramPlateBus.shared.setVideoSample(
            BroadcastProgramPlateBus.VideoSample(
                pixelBuffer: pixelBuffer,
                displayTransform: currentTransform()
            ),
            animating: isPlaybackRunning()
        )
    }

    private func currentURL() -> URL? {
        stateLock.lock()
        defer { stateLock.unlock() }
        return presentedURL
    }

    private func setPresentedURL(_ url: URL?) {
        stateLock.lock()
        presentedURL = url
        stateLock.unlock()
    }

    private func currentVideoOutput() -> AVPlayerItemVideoOutput? {
        stateLock.lock()
        defer { stateLock.unlock() }
        return videoOutput
    }

    private func setVideoOutput(_ output: AVPlayerItemVideoOutput?) {
        stateLock.lock()
        videoOutput = output
        stateLock.unlock()
    }

    private func currentTransform() -> CGAffineTransform {
        stateLock.lock()
        defer { stateLock.unlock() }
        return playbackTransform
    }

    private func setPlaybackTransform(_ transform: CGAffineTransform) {
        stateLock.lock()
        playbackTransform = transform
        stateLock.unlock()
    }

    private func isPlaybackRunning() -> Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        return playbackRunning
    }

    private func setPlaybackRunning(_ running: Bool) {
        stateLock.lock()
        playbackRunning = running
        stateLock.unlock()
    }

    private func publish(isVideo: Bool, isPlaying: Bool) {
        DispatchQueue.main.async {
            BroadcastProgramPlateTransport.shared.apply(isVideo: isVideo, isPlaying: isPlaying)
        }
    }

    private func stopVideoLocked() {
        pump?.cancel()
        pump = nil
        setVideoOutput(nil)
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
        let active = player
        player = nil
        DispatchQueue.main.async {
            active?.pause()
        }
    }

    private func coverBitmap(from image: CGImage) -> BroadcastProgramPlateBus.Frame? {
        let source = CIImage(cgImage: image)
        let extent = source.extent
        guard extent.width > 1, extent.height > 1 else { return nil }
        let scale = max(CGFloat(plateWidth) / extent.width, CGFloat(plateHeight) / extent.height)
        let scaled = source.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let scaledExtent = scaled.extent
        let crop = CGRect(
            x: scaledExtent.midX - CGFloat(plateWidth) / 2,
            y: scaledExtent.midY - CGFloat(plateHeight) / 2,
            width: CGFloat(plateWidth),
            height: CGFloat(plateHeight)
        )
        return coverBitmap(from: scaled, crop: crop)
    }

    /// RGBA bitmap, flipped the same way as the other on-air sprites.
    private func coverBitmap(from image: CIImage, crop: CGRect) -> BroadcastProgramPlateBus.Frame? {
        let shifted = image.transformed(by: CGAffineTransform(translationX: -crop.origin.x, y: -crop.origin.y))
        let flipped = shifted.transformed(by: CGAffineTransform(
            a: 1,
            b: 0,
            c: 0,
            d: -1,
            tx: 0,
            ty: CGFloat(plateHeight)
        ))
        var data = Data(count: plateWidth * plateHeight * 4)
        data.withUnsafeMutableBytes { raw in
            guard let base = raw.baseAddress else { return }
            context.render(
                flipped,
                toBitmap: base,
                rowBytes: plateWidth * 4,
                bounds: CGRect(x: 0, y: 0, width: plateWidth, height: plateHeight),
                format: .RGBA8,
                colorSpace: CGColorSpaceCreateDeviceRGB()
            )
        }
        premultiply(&data)
        return BroadcastProgramPlateBus.Frame(rgba: data, width: plateWidth, height: plateHeight)
    }

    private func premultiply(_ data: inout Data) {
        data.withUnsafeMutableBytes { raw in
            guard let bytes = raw.bindMemory(to: UInt8.self).baseAddress else { return }
            let count = raw.count / 4
            for index in 0..<count {
                let pixel = bytes.advanced(by: index * 4)
                let alpha = UInt16(pixel[3])
                if alpha == 255 || alpha == 0 { continue }
                pixel[0] = UInt8((UInt16(pixel[0]) * alpha) / 255)
                pixel[1] = UInt8((UInt16(pixel[1]) * alpha) / 255)
                pixel[2] = UInt8((UInt16(pixel[2]) * alpha) / 255)
            }
        }
    }

    private static func loadImage(at url: URL) -> CGImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 1920
        ] as CFDictionary
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options)
            ?? CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
}
