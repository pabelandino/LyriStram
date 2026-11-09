import CoreGraphics
import CoreImage
import CoreText
import Foundation
import ImageIO
import QuartzCore
import EasyStreamCore
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// CPU bitmaps for on-air graphics. Decode and text layout run off the main thread.
/// The Metal compositor turns these into GPU sprites; SwiftUI does not animate them.
public final class BroadcastMetalSpriteBus: @unchecked Sendable {
    public static let shared = BroadcastMetalSpriteBus()

    struct Bitmap: @unchecked Sendable {
        var rgba: Data
        var width: Int
        var height: Int
        var centerX: Float
        var centerY: Float
        var widthFraction: Float
        var heightFraction: Float
        var uniformSquare: Bool
        var spinDuration: Float
        var pauseDuration: Float
        var scrollUVPerSecond: Float
        var playsSequence: Bool
        var sequenceStart: Double
        var enterDelay: Float
        var enterDuration: Float
        var exitDelay: Float
        var exitDuration: Float
        var slideFraction: Float
        var enterScale: Float
        var sourceID: UUID?
        var slidesVertically: Bool
        /// Point speed lives in `scrollUVPerSecond`. The compositor shows a 1:1 window of the strip.
        var matchesTextScale: Bool
        /// When set, a new identity replays the entrance instead of keeping the old clock.
        var motionIdentity: String
        /// Holds at full opacity after the entrance. Motion runs only during enter and exit.
        var settlesVisible: Bool

        init(
            rgba: Data,
            width: Int,
            height: Int,
            centerX: Float,
            centerY: Float,
            widthFraction: Float,
            heightFraction: Float,
            uniformSquare: Bool,
            spinDuration: Float,
            pauseDuration: Float,
            scrollUVPerSecond: Float,
            playsSequence: Bool = false,
            sequenceStart: Double = 0,
            enterDelay: Float = 0,
            enterDuration: Float = 0,
            exitDelay: Float = 0,
            exitDuration: Float = 0,
            slideFraction: Float = 0,
            enterScale: Float = 1,
            sourceID: UUID? = nil,
            slidesVertically: Bool = false,
            matchesTextScale: Bool = false,
            motionIdentity: String = "",
            settlesVisible: Bool = false
        ) {
            self.rgba = rgba
            self.width = width
            self.height = height
            self.centerX = centerX
            self.centerY = centerY
            self.widthFraction = widthFraction
            self.heightFraction = heightFraction
            self.uniformSquare = uniformSquare
            self.spinDuration = spinDuration
            self.pauseDuration = pauseDuration
            self.scrollUVPerSecond = scrollUVPerSecond
            self.playsSequence = playsSequence
            self.sequenceStart = sequenceStart
            self.enterDelay = enterDelay
            self.enterDuration = enterDuration
            self.exitDelay = exitDelay
            self.exitDuration = exitDuration
            self.slideFraction = slideFraction
            self.enterScale = enterScale
            self.sourceID = sourceID
            self.slidesVertically = slidesVertically
            self.matchesTextScale = matchesTextScale
            self.motionIdentity = motionIdentity
            self.settlesVisible = settlesVisible
        }
    }

    enum Kind: Sendable {
        case logo
        case lowerThird
        case text
        case clock
        case countdown
        case lyriora
    }

    struct Request: Sendable {
        var kind: Kind
        var centerX: Float
        var centerY: Float
        var widthFraction: Float
        var heightFraction: Float
        var uniformSquare: Bool
        var logoPath: String?
        var title: String
        var subtitle: String
        var accentHex: String
        var textHex: String
        var subtitleHex: String
        var gradientEndHex: String?
        var spins: Bool
        var spinDuration: Float
        var pauseDuration: Float
        var scrollUVPerSecond: Float
        var titleFont: BroadcastFontPreset
        var subtitleFont: BroadcastFontPreset
        var titleFontScale: Float
        var subtitleFontScale: Float
        var style: BroadcastLowerThirdStyle
        var thirdLine: String
        var playsSequence: Bool
        var animateIn: Double
        var hold: Double
        var animateOut: Double
        var sourceID: UUID
        var tickerBackgroundHex: String
        var tickerUsesGradient: Bool
        var tickerGradientStartHex: String
        var tickerGradientEndHex: String
        var tickerSpeed: Double
        var gradientAngle: Double
        var clockShowsSeconds: Bool
        var clockShowsDate: Bool
        var clockUse24Hour: Bool
        var clockShowsBackground: Bool
        var countdownTarget: Date?
        var countdownSeconds: Int
        var lyrioraStyle: LyrioraVisualStyle = .classic
        var lyrioraFullScreen: Bool = false
        var reduceMotion: Bool = false
    }

    private let lock = NSLock()
    private var generation: UInt64 = 0
    private var requestSerial: UInt64 = 0
    private var bitmaps: [Bitmap] = []
    private var timepieceRequests: [Request] = []
    private var renderedTimepieceKey: [UUID: String] = [:]
    private var renderedTimepieceSecond: Int = -1
    private var countdownAnchors: [UUID: Date] = [:]
    private var lyrioraResting: [UUID: Bitmap] = [:]
    private var lyrioraEpoch: [UUID: UInt64] = [:]
    private var listeners: [@Sendable () -> Void] = []
    private let imageContext = CIContext(options: [.cacheIntermediates: false])

    private init() {}

    func currentGeneration() -> UInt64 {
        lock.lock()
        defer { lock.unlock() }
        return generation
    }

    func presentsMotion(at time: CFTimeInterval = CACurrentMediaTime()) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return bitmaps.contains { bitmap in
            if bitmap.spinDuration > 0 || bitmap.scrollUVPerSecond > 0 { return true }
            if bitmap.settlesVisible {
                let elapsed = time - bitmap.sequenceStart
                let enterEnd = Double(bitmap.enterDelay + bitmap.enterDuration) + 0.08
                let exitStart = Double(bitmap.exitDelay)
                let exitEnd = exitStart + Double(bitmap.exitDuration) + 0.08
                return elapsed < enterEnd || (elapsed >= exitStart && elapsed < exitEnd)
            }
            guard bitmap.playsSequence else { return false }
            let end = bitmap.sequenceStart + Double(bitmap.exitDelay + bitmap.exitDuration) + 0.08
            return time < end
        }
    }

    /// Starts the exit slide for a ticker that is already on air. Returns false when no sprite is ready.
    public func beginExit(sourceID: UUID) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let now = CACurrentMediaTime()
        var changed = false
        for index in bitmaps.indices {
            guard bitmaps[index].sourceID == sourceID, bitmaps[index].playsSequence else { continue }
            guard bitmaps[index].exitDelay > 100_000 else { continue }
            let elapsed = now - bitmaps[index].sequenceStart
            bitmaps[index].exitDelay = Float(max(0, elapsed))
            changed = true
        }
        if changed {
            generation &+= 1
        }
        return changed
    }

    func copyBitmapsIfGenerationChanged(from known: UInt64) -> (generation: UInt64, bitmaps: [Bitmap])? {
        lock.lock()
        defer { lock.unlock() }
        guard generation != known else { return nil }
        return (generation, bitmaps)
    }

    func current() -> (generation: UInt64, bitmaps: [Bitmap]) {
        lock.lock()
        defer { lock.unlock() }
        return (generation, bitmaps)
    }

    public func publish(_ layers: [ProgramFeedWidgetLayer]) {
        let requests = layers.map(Self.request(from:))
        lock.lock()
        requestSerial &+= 1
        let token = requestSerial
        if requests.isEmpty {
            let absorbed = absorbLyrioraExits(requests: [], settled: [], now: CACurrentMediaTime())
            generation &+= 1
            bitmaps = absorbed.bitmaps
            timepieceRequests = []
            renderedTimepieceKey = [:]
            renderedTimepieceSecond = -1
            countdownAnchors = [:]
            if absorbed.bitmaps.isEmpty {
                lyrioraResting = [:]
                lyrioraEpoch = [:]
            }
            let removals = absorbed.removals
            lock.unlock()
            for removal in removals {
                scheduleLyrioraRemoval(removal)
            }
            notifyListeners()
            return
        }
        let anchors = countdownAnchors
        lock.unlock()

        DispatchQueue.global(qos: .userInitiated).async {
            let now = Date()
            let countdownStarts = self.countdownStarts(for: requests, existing: anchors, now: now)
            let sequenceStart = CACurrentMediaTime()
            let built = requests.flatMap { request -> [Bitmap] in
                self.rasterize(request, now: now, countdownStart: countdownStarts[request.sourceID]).map { bitmap in
                    var copy = bitmap
                    copy.sourceID = request.sourceID
                    if copy.playsSequence {
                        copy.sequenceStart = sequenceStart
                    }
                    return copy
                }
            }
            self.lock.lock()
            guard token == self.requestSerial else {
                self.lock.unlock()
                return
            }
            let timepieces = requests.filter { $0.kind == .clock || $0.kind == .countdown }
            self.timepieceRequests = timepieces
            self.countdownAnchors = countdownStarts
            self.renderedTimepieceKey = Dictionary(uniqueKeysWithValues: timepieces.map { request in
                (request.sourceID, self.timepieceLabel(request, now: now, countdownStart: countdownStarts[request.sourceID]))
            })
            self.renderedTimepieceSecond = Int(now.timeIntervalSince1970)
            let settled = Self.keepingMotion(Self.motionClocks(from: self.bitmaps), in: built)
            let absorbed = self.absorbLyrioraExits(requests: requests, settled: settled, now: sequenceStart)
            self.generation &+= 1
            self.bitmaps = absorbed.bitmaps
            let removals = absorbed.removals
            self.lock.unlock()
            for removal in removals {
                self.scheduleLyrioraRemoval(removal)
            }
            self.notifyListeners()
        }
    }

    func addListener(_ listener: @escaping @Sendable () -> Void) {
        lock.lock()
        listeners.append(listener)
        lock.unlock()
    }

    private struct LyrioraRemoval {
        var id: UUID
        var epoch: UInt64
        var delay: Double
    }

    /// Lower thirds swap lyrics in place. The exit plays only when that widget leaves the air.
    /// Full-screen still fades when Lyriora clears the verse.
    private func absorbLyrioraExits(
        requests: [Request],
        settled: [Bitmap],
        now: CFTimeInterval
    ) -> (bitmaps: [Bitmap], removals: [LyrioraRemoval]) {
        let liveIDs = Set(requests.map(\.sourceID))
        var output = settled
        var removals: [LyrioraRemoval] = []
        for request in requests where request.kind == .lyriora {
            if !request.lyrioraFullScreen {
                if let fresh = output.last(where: { $0.sourceID == request.sourceID }) {
                    lyrioraResting[request.sourceID] = fresh
                }
                lyrioraEpoch[request.sourceID, default: 0] &+= 1
                continue
            }
            let headline = request.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let body = request.subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
            if !headline.isEmpty || !body.isEmpty {
                if let fresh = output.last(where: { $0.sourceID == request.sourceID }) {
                    lyrioraResting[request.sourceID] = fresh
                }
                lyrioraEpoch[request.sourceID, default: 0] &+= 1
                continue
            }
            guard var fading = lyrioraResting[request.sourceID] else { continue }
            if fading.exitDelay > 100_000 {
                fading.exitDelay = Float(max(0, now - fading.sequenceStart))
                lyrioraResting[request.sourceID] = fading
                lyrioraEpoch[request.sourceID, default: 0] &+= 1
                removals.append(
                    LyrioraRemoval(
                        id: request.sourceID,
                        epoch: lyrioraEpoch[request.sourceID] ?? 0,
                        delay: Double(fading.exitDuration) + 0.08
                    )
                )
            }
            output.removeAll { $0.sourceID == request.sourceID }
            output.append(fading)
        }

        for bitmap in bitmaps {
            guard let id = bitmap.sourceID,
                  bitmap.motionIdentity.hasPrefix("lower\u{1}"),
                  !liveIDs.contains(id),
                  !output.contains(where: { $0.sourceID == id }) else { continue }
            var fading = bitmap
            if fading.exitDelay > 100_000 {
                fading.exitDelay = Float(max(0, now - fading.sequenceStart))
                lyrioraEpoch[id, default: 0] &+= 1
                removals.append(
                    LyrioraRemoval(
                        id: id,
                        epoch: lyrioraEpoch[id] ?? 0,
                        delay: Double(fading.exitDuration) + 0.08
                    )
                )
            }
            lyrioraResting[id] = fading
            output.append(fading)
        }

        let retained = liveIDs.union(removals.map(\.id))
        lyrioraResting = lyrioraResting.filter { retained.contains($0.key) }
        return (output, removals)
    }

    private func scheduleLyrioraRemoval(_ removal: LyrioraRemoval) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + removal.delay) { [weak self] in
            self?.removeLyrioraSprite(id: removal.id, epoch: removal.epoch)
        }
    }

    private func removeLyrioraSprite(id: UUID, epoch: UInt64) {
        lock.lock()
        guard lyrioraEpoch[id] == epoch else {
            lock.unlock()
            return
        }
        let before = bitmaps.count
        bitmaps.removeAll { $0.sourceID == id }
        lyrioraResting[id] = nil
        let changed = bitmaps.count != before
        if changed {
            generation &+= 1
        }
        lock.unlock()
        if changed {
            notifyListeners()
        }
    }

    private func notifyListeners() {
        lock.lock()
        let callbacks = listeners
        lock.unlock()
        DispatchQueue.main.async {
            callbacks.forEach { $0() }
        }
    }

    private static var prefersReducedMotion: Bool {
        #if os(iOS)
        UIAccessibility.isReduceMotionEnabled
        #elseif os(macOS)
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        #else
        false
        #endif
    }

    /// Redraws clock and countdown sprites when the shown second changes. Other widgets stay put.
    func refreshTimepieces(now: Date = Date()) -> Bool {
        let second = Int(now.timeIntervalSince1970)
        lock.lock()
        if timepieceRequests.isEmpty || second == renderedTimepieceSecond {
            lock.unlock()
            return false
        }
        let requests = timepieceRequests
        let anchors = countdownAnchors
        let previous = renderedTimepieceKey
        lock.unlock()
        guard !requests.isEmpty else { return false }

        var updates: [(UUID, Bitmap, String)] = []
        for request in requests {
            let label = timepieceLabel(request, now: now, countdownStart: anchors[request.sourceID])
            if previous[request.sourceID] == label { continue }
            guard let bitmap = timepieceBitmap(request, now: now, countdownStart: anchors[request.sourceID]) else { continue }
            updates.append((request.sourceID, bitmap, label))
        }
        guard !updates.isEmpty else {
            lock.lock()
            renderedTimepieceSecond = second
            lock.unlock()
            return false
        }

        lock.lock()
        defer { lock.unlock() }
        let live = Set(timepieceRequests.map(\.sourceID))
        var changed = false
        for update in updates where live.contains(update.0) {
            bitmaps.removeAll { $0.sourceID == update.0 }
            bitmaps.append(update.1)
            renderedTimepieceKey[update.0] = update.2
            changed = true
        }
        renderedTimepieceSecond = second
        if changed {
            generation &+= 1
        }
        return changed
    }

    private func countdownStarts(for requests: [Request], existing: [UUID: Date], now: Date) -> [UUID: Date] {
        let ids = Set(requests.filter { $0.kind == .countdown && $0.countdownTarget == nil }.map(\.sourceID))
        var starts = existing.filter { ids.contains($0.key) }
        for id in ids where starts[id] == nil {
            starts[id] = now
        }
        return starts
    }

    /// Widgets already on air keep their entrance clock. A fresh publish would replay it.
    private struct KeptMotion {
        var sequenceStart: Double
        var exitDelays: [Float]
        var motionIdentity: String
    }

    private static func motionClocks(from bitmaps: [Bitmap]) -> [UUID: KeptMotion] {
        var clocks: [UUID: KeptMotion] = [:]
        for bitmap in bitmaps {
            guard let id = bitmap.sourceID, bitmap.playsSequence else { continue }
            var clock = clocks[id] ?? KeptMotion(
                sequenceStart: bitmap.sequenceStart,
                exitDelays: [],
                motionIdentity: bitmap.motionIdentity
            )
            clock.sequenceStart = min(clock.sequenceStart, bitmap.sequenceStart)
            clock.exitDelays.append(bitmap.exitDelay)
            clock.motionIdentity = bitmap.motionIdentity
            clocks[id] = clock
        }
        return clocks
    }

    private static func keepingMotion(_ clocks: [UUID: KeptMotion], in bitmaps: [Bitmap]) -> [Bitmap] {
        var pieceIndex: [UUID: Int] = [:]
        return bitmaps.map { bitmap in
            guard let id = bitmap.sourceID, bitmap.playsSequence, let clock = clocks[id] else { return bitmap }
            if !bitmap.motionIdentity.isEmpty, bitmap.motionIdentity != clock.motionIdentity {
                return bitmap
            }
            let piece = pieceIndex[id, default: 0]
            pieceIndex[id] = piece + 1
            var copy = bitmap
            copy.sequenceStart = clock.sequenceStart
            if piece < clock.exitDelays.count, clock.exitDelays[piece] < 100_000, copy.exitDelay > 100_000 {
                copy.exitDelay = clock.exitDelays[piece]
            }
            return copy
        }
    }

    private static func request(from layer: ProgramFeedWidgetLayer) -> Request {
        let configuration = layer.configuration
        let template = configuration.resolvedTemplate
        let isLogo = template == .animatedLogo || template == .logo
        let isLowerThird = template == .lowerThird || template == .lowerThirdPro
        let kind: Kind = switch template {
        case .animatedLogo, .logo: .logo
        case .lowerThird, .lowerThirdPro: .lowerThird
        case .clock: .clock
        case .countdown: .countdown
        case .lyriora: .lyriora
        default: .text
        }
        let speed = min(max(configuration.animationSpeed, 0.25), 3)
        let spin = Float(1.0 / (0.45 * speed))
        let text = configuration.tickerText.isEmpty
            ? (configuration.tickerTexts.first ?? configuration.title)
            : configuration.tickerText
        let gradient = configuration.resolvedLowerThirdGradient(fallbackAccent: configuration.accentColorHex)
        let isTicker = template == .ticker || template == .textBanner
        let accent = isLowerThird && configuration.resolvedUseLowerThirdGradient
            ? gradient.startColorHex
            : (configuration.accentColorHex ?? "1A1A1A")
        return Request(
            kind: kind,
            centerX: Float(configuration.placement.normalizedCenterX),
            centerY: Float(configuration.placement.normalizedCenterY),
            widthFraction: Float(configuration.placement.widthFraction),
            heightFraction: Float(configuration.placement.heightFraction),
            uniformSquare: isLogo,
            logoPath: layer.logoURL?.path,
            title: kind == .text ? text : configuration.title,
            subtitle: configuration.subtitle ?? "",
            accentHex: accent,
            textHex: kind == .text ? configuration.resolvedTickerTextColorHex : configuration.resolvedTitleColorHex,
            subtitleHex: configuration.resolvedSubtitleColorHex,
            gradientEndHex: isLowerThird && configuration.resolvedUseLowerThirdGradient ? gradient.endColorHex : nil,
            spins: isLogo && configuration.logoAnimation != .none,
            spinDuration: spin,
            pauseDuration: spin,
            scrollUVPerSecond: isTicker ? 1 : 0,
            titleFont: configuration.titleFont,
            subtitleFont: configuration.subtitleFont,
            titleFontScale: Float(configuration.titleFontSize / 28),
            subtitleFontScale: Float(configuration.subtitleFontSize / 16),
            style: configuration.resolvedLowerThirdStyle,
            thirdLine: configuration.lowerThirdThirdLine,
            playsSequence: isLowerThird,
            animateIn: configuration.animateInSeconds,
            hold: configuration.holdDurationSeconds,
            animateOut: configuration.animateOutSeconds,
            sourceID: layer.id,
            tickerBackgroundHex: configuration.resolvedTickerBackgroundHex,
            tickerUsesGradient: isTicker && configuration.resolvedUseTickerGradient,
            tickerGradientStartHex: configuration.tickerGradient.startColorHex,
            tickerGradientEndHex: configuration.tickerGradient.endColorHex,
            tickerSpeed: configuration.tickerSpeed,
            gradientAngle: isLowerThird ? gradient.angleDegrees : configuration.tickerGradient.angleDegrees,
            clockShowsSeconds: configuration.clockShowsSeconds,
            clockShowsDate: configuration.clockShowsDate,
            clockUse24Hour: configuration.clockUse24Hour,
            clockShowsBackground: configuration.resolvedClockShowsBackground,
            countdownTarget: configuration.countdownTargetDate,
            countdownSeconds: configuration.countdownSeconds,
            lyrioraStyle: configuration.resolvedLyrioraStyle,
            lyrioraFullScreen: configuration.resolvedLyrioraMode == .fullScreen,
            reduceMotion: Self.prefersReducedMotion
        )
    }

    private func rasterize(_ request: Request, now: Date, countdownStart: Date?) -> [Bitmap] {
        if request.kind == .clock || request.kind == .countdown {
            return timepieceBitmap(request, now: now, countdownStart: countdownStart).map { [$0] } ?? []
        }
        if request.kind == .lyriora {
            return lyrioraBitmap(for: request).map { [$0] } ?? []
        }
        if request.kind == .lowerThird {
            return lowerThirdPieces(request)
        }
        if request.scrollUVPerSecond > 0 {
            return tickerPieces(request)
        }
        if request.kind == .logo,
           let path = request.logoPath,
           let image = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)
            .flatMap({ CGImageSourceCreateImageAtIndex($0, 0, nil) }),
           let bitmap = rgba(from: image, maxSide: 512) {
            return [Bitmap(
                rgba: bitmap.data,
                width: bitmap.width,
                height: bitmap.height,
                centerX: request.centerX,
                centerY: request.centerY,
                widthFraction: request.widthFraction,
                heightFraction: request.heightFraction,
                uniformSquare: request.uniformSquare,
                spinDuration: request.spins ? request.spinDuration : 0,
                pauseDuration: request.spins ? request.pauseDuration : 0,
                scrollUVPerSecond: 0
            )]
        }

        let pixels = Self.textCard(
            title: request.title,
            subtitle: request.subtitle,
            accentHex: request.accentHex,
            textHex: request.textHex
        )
        return [Bitmap(
            rgba: pixels.data,
            width: pixels.width,
            height: pixels.height,
            centerX: request.centerX,
            centerY: request.centerY,
            widthFraction: request.widthFraction,
            heightFraction: request.heightFraction,
            uniformSquare: false,
            spinDuration: 0,
            pauseDuration: 0,
            scrollUVPerSecond: request.scrollUVPerSecond
        )]
    }

    private func rgba(from image: CGImage, maxSide: Int) -> (data: Data, width: Int, height: Int)? {
        let source = CIImage(cgImage: image)
        let longest = max(source.extent.width, source.extent.height)
        let scale = min(1, CGFloat(maxSide) / max(longest, 1))
        let scaled = source.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let extent = scaled.extent.integral
        let width = max(1, Int(extent.width))
        let height = max(1, Int(extent.height))
        let upright = scaled.transformed(by: CGAffineTransform(
            a: 1,
            b: 0,
            c: 0,
            d: -1,
            tx: -extent.origin.x,
            ty: extent.maxY
        ))
        var data = Data(count: width * height * 4)
        data.withUnsafeMutableBytes { raw in
            guard let base = raw.baseAddress else { return }
            imageContext.render(
                upright,
                toBitmap: base,
                rowBytes: width * 4,
                bounds: CGRect(x: 0, y: 0, width: width, height: height),
                format: .RGBA8,
                colorSpace: CGColorSpaceCreateDeviceRGB()
            )
        }
        Self.premultiply(&data)
        return (data, width, height)
    }

    private static func premultiply(_ data: inout Data) {
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


    static func blitAspectFit(
        _ logo: (data: Data, width: Int, height: Int),
        into dest: inout Data,
        destWidth: Int,
        destHeight: Int,
        slot: CGRect
    ) {
        let scale = min(slot.width / CGFloat(logo.width), slot.height / CGFloat(logo.height))
        let drawW = max(1, Int((CGFloat(logo.width) * scale).rounded()))
        let drawH = max(1, Int((CGFloat(logo.height) * scale).rounded()))
        let originX = Int(slot.midX.rounded()) - drawW / 2
        let originY = Int(slot.midY.rounded()) - drawH / 2
        dest.withUnsafeMutableBytes { destRaw in
            logo.data.withUnsafeBytes { srcRaw in
                guard let destBase = destRaw.bindMemory(to: UInt8.self).baseAddress,
                      let srcBase = srcRaw.bindMemory(to: UInt8.self).baseAddress else { return }
                for row in 0..<drawH {
                    let srcY = min(logo.height - 1, row * logo.height / drawH)
                    let destY = originY + row
                    guard destY >= 0, destY < destHeight else { continue }
                    for column in 0..<drawW {
                        let srcX = min(logo.width - 1, column * logo.width / drawW)
                        let destX = originX + column
                        guard destX >= 0, destX < destWidth else { continue }
                        let srcIndex = (srcY * logo.width + srcX) * 4
                        let destIndex = (destY * destWidth + destX) * 4
                        let alpha = Int(srcBase[srcIndex + 3])
                        guard alpha > 0 else { continue }
                        let inv = 255 - alpha
                        for channel in 0..<3 {
                            let source = Int(srcBase[srcIndex + channel])
                            let destination = Int(destBase[destIndex + channel])
                            destBase[destIndex + channel] = UInt8(min(255, source + destination * inv / 255))
                        }
                        let destAlpha = Int(destBase[destIndex + 3])
                        destBase[destIndex + 3] = UInt8(min(255, alpha + destAlpha * inv / 255))
                    }
                }
            }
        }
    }

    private static func textCard(
        title: String,
        subtitle: String,
        accentHex: String,
        textHex: String
    ) -> (data: Data, width: Int, height: Int) {
        let width = 960
        let height = 180
        var data = Data(count: width * height * 4)
        data.withUnsafeMutableBytes { raw in
            guard let context = CGContext(
                data: raw.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return }
            context.setFillColor(cgColor(hex: accentHex, alpha: 0.82))
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
            context.translateBy(x: 0, y: CGFloat(height))
            context.scaleBy(x: 1, y: -1)
            draw(title, hex: textHex, size: 54, in: context, x: 28, y: subtitle.isEmpty ? 64 : 36)
            if !subtitle.isEmpty {
                draw(subtitle, hex: textHex, size: 28, in: context, x: 28, y: 96)
            }
        }
        return (data, width, height)
    }

    static func draw(_ text: String, hex: String, size: CGFloat, in context: CGContext, x: CGFloat, y: CGFloat) {
        let font = CTFontCreateWithName("Helvetica-Bold" as CFString, size, nil)
        let attributes: [CFString: Any] = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: cgColor(hex: hex, alpha: 1)
        ]
        let attributed = CFAttributedStringCreate(kCFAllocatorDefault, text as CFString, attributes as CFDictionary)
        let line = CTLineCreateWithAttributedString(attributed!)
        context.textPosition = CGPoint(x: x, y: y)
        CTLineDraw(line, context)
    }

    static func cgColor(hex: String, alpha: CGFloat) -> CGColor {
        var raw = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.hasPrefix("#") { raw.removeFirst() }
        if raw.count >= 8, let value = UInt64(String(raw.prefix(8)), radix: 16) {
            let storedAlpha = CGFloat((value >> 24) & 0xFF) / 255
            return CGColor(
                red: CGFloat((value >> 16) & 0xFF) / 255,
                green: CGFloat((value >> 8) & 0xFF) / 255,
                blue: CGFloat(value & 0xFF) / 255,
                alpha: storedAlpha * alpha
            )
        }
        let rgb = raw.count >= 6 ? String(raw.prefix(6)) : "FFFFFF"
        let value = UInt64(rgb, radix: 16) ?? 0xFFFFFF
        return CGColor(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: alpha
        )
    }

    static func drawLinearGradient(
        in context: CGContext,
        bounds: CGRect,
        startHex: String,
        endHex: String,
        angle: Double
    ) {
        let startColor = cgColor(hex: startHex, alpha: 1)
        let endColor = cgColor(hex: endHex, alpha: 1)
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [startColor, endColor] as CFArray,
            locations: [0, 1]
        ) else {
            context.setFillColor(startColor)
            context.fill(bounds)
            return
        }
        let radians = angle * .pi / 180
        let dx = CGFloat(cos(radians)) * bounds.width * 0.5
        let dy = CGFloat(sin(radians)) * bounds.height * 0.5
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: bounds.midX - dx, y: bounds.midY - dy),
            end: CGPoint(x: bounds.midX + dx, y: bounds.midY + dy),
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
        )
    }

    static func loadCGImage(path: String) -> CGImage? {
        guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    /// Draws in the flipped lower-third context: larger `y` sits lower on screen.
    static func drawAligned(
        _ text: String,
        hex: String,
        size: CGFloat,
        fontName: String,
        in context: CGContext,
        rect: CGRect,
        center: Bool,
        clips: Bool = true
    ) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let fittedSize = min(max(10, size), max(10, rect.height * 0.72))
        let font = CTFontCreateWithName(fontName as CFString, fittedSize, nil)
        let attributes: [CFString: Any] = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: cgColor(hex: hex, alpha: 1)
        ]
        guard let attributed = CFAttributedStringCreate(kCFAllocatorDefault, trimmed as CFString, attributes as CFDictionary) else { return }
        let line = CTLineCreateWithAttributedString(attributed)
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        let lineWidth = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, nil))
        let x = center ? rect.midX - lineWidth / 2 : rect.minX
        // Glyphs rise toward smaller y. Keep the whole cap height inside the rect.
        let baseline = rect.midY + (ascent - descent) / 2
        context.saveGState()
        if clips {
            context.clip(to: rect.insetBy(dx: -6, dy: -1))
        }
        context.textPosition = CGPoint(x: x, y: baseline)
        CTLineDraw(line, context)
        context.restoreGState()
    }
}
