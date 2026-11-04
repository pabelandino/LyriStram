import CoreGraphics
import CoreImage
import CoreText
import Foundation
import ImageIO
import EasyStreamCore

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
    }

    private enum Kind: Sendable {
        case logo
        case lowerThird
        case text
    }

    private struct Request: Sendable {
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
    }

    private let lock = NSLock()
    private var generation: UInt64 = 0
    private var requestSerial: UInt64 = 0
    private var bitmaps: [Bitmap] = []
    private let imageContext = CIContext(options: [.cacheIntermediates: false])

    private init() {}

    func presentsMotion() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return bitmaps.contains { $0.spinDuration > 0 || $0.scrollUVPerSecond > 0 }
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
            generation &+= 1
            bitmaps = []
            lock.unlock()
            return
        }
        lock.unlock()

        DispatchQueue.global(qos: .userInitiated).async {
            let built = requests.map { self.rasterize($0) }
            self.lock.lock()
            defer { self.lock.unlock() }
            guard token == self.requestSerial else { return }
            self.generation &+= 1
            self.bitmaps = built
        }
    }

    private static func request(from layer: ProgramFeedWidgetLayer) -> Request {
        let configuration = layer.configuration
        let template = configuration.resolvedTemplate
        let isLogo = template == .animatedLogo || template == .logo
        let isLowerThird = template == .lowerThird || template == .lowerThirdPro
        let kind: Kind = isLogo ? .logo : (isLowerThird ? .lowerThird : .text)
        let speed = min(max(configuration.animationSpeed, 0.25), 3)
        let spin = Float(1.0 / (0.45 * speed))
        let text = configuration.tickerText.isEmpty
            ? (configuration.tickerTexts.first ?? configuration.title)
            : configuration.tickerText
        let gradient = configuration.resolvedLowerThirdGradient(fallbackAccent: configuration.accentColorHex)
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
            scrollUVPerSecond: (template == .ticker || template == .textBanner)
                ? Float(max(configuration.tickerSpeed, 20) / 900)
                : 0
        )
    }

    private func rasterize(_ request: Request) -> Bitmap {
        if request.kind == .lowerThird {
            return lowerThirdCard(request)
        }
        if request.kind == .logo,
           let path = request.logoPath,
           let image = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)
            .flatMap({ CGImageSourceCreateImageAtIndex($0, 0, nil) }),
           let bitmap = rgba(from: image, maxSide: 512) {
            return Bitmap(
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
            )
        }

        let pixels = Self.textCard(
            title: request.title,
            subtitle: request.subtitle,
            accentHex: request.accentHex,
            textHex: request.textHex
        )
        return Bitmap(
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
        )
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

    private func lowerThirdCard(_ request: Request) -> Bitmap {
        let height = 220
        let aspect = CGFloat(request.widthFraction / max(request.heightFraction, 0.04))
        let width = min(1600, max(640, Int((CGFloat(height) * aspect).rounded())))
        var data = Data(count: width * height * 4)
        let logoSide = Int(CGFloat(height) * 0.62)
        let logoOrigin = CGPoint(x: 22, y: CGFloat(height - logoSide) / 2)
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
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)
            context.addPath(CGPath(roundedRect: bounds, cornerWidth: 18, cornerHeight: 18, transform: nil))
            context.clip()
            if let endHex = request.gradientEndHex {
                let colors = [
                    Self.cgColor(hex: request.accentHex, alpha: 0.94),
                    Self.cgColor(hex: endHex, alpha: 0.94)
                ] as CFArray
                if let gradient = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: colors,
                    locations: [0, 1]
                ) {
                    context.drawLinearGradient(
                        gradient,
                        start: CGPoint(x: 0, y: 0),
                        end: CGPoint(x: width, y: height),
                        options: []
                    )
                }
            } else {
                context.setFillColor(Self.cgColor(hex: request.accentHex, alpha: 0.92))
                context.fill(bounds)
            }
            context.translateBy(x: 0, y: CGFloat(height))
            context.scaleBy(x: 1, y: -1)
            let textX = logoOrigin.x + CGFloat(logoSide) + 18
            Self.draw(request.title, hex: request.textHex, size: 42, in: context, x: textX, y: request.subtitle.isEmpty ? 86 : 58)
            if !request.subtitle.isEmpty {
                Self.draw(request.subtitle, hex: request.subtitleHex, size: 26, in: context, x: textX, y: 112)
            }
        }
        if let path = request.logoPath,
           let image = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)
            .flatMap({ CGImageSourceCreateImageAtIndex($0, 0, nil) }),
           let logo = rgba(from: image, maxSide: 256) {
            Self.blitAspectFit(
                logo,
                into: &data,
                destWidth: width,
                destHeight: height,
                slot: CGRect(x: logoOrigin.x, y: logoOrigin.y, width: CGFloat(logoSide), height: CGFloat(logoSide))
            )
        }
        return Bitmap(
            rgba: data,
            width: width,
            height: height,
            centerX: request.centerX,
            centerY: request.centerY,
            widthFraction: request.widthFraction,
            heightFraction: request.heightFraction,
            uniformSquare: false,
            spinDuration: 0,
            pauseDuration: 0,
            scrollUVPerSecond: 0
        )
    }

    private static func blitAspectFit(
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

    private static func draw(_ text: String, hex: String, size: CGFloat, in context: CGContext, x: CGFloat, y: CGFloat) {
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

    private static func cgColor(hex: String, alpha: CGFloat) -> CGColor {
        var raw = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.hasPrefix("#") { raw.removeFirst() }
        let rgb = raw.count >= 6 ? String(raw.prefix(6)) : "FFFFFF"
        let value = UInt64(rgb, radix: 16) ?? 0xFFFFFF
        return CGColor(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: alpha
        )
    }
}
