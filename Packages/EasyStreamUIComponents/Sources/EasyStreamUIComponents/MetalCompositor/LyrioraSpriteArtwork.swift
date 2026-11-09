import CoreGraphics
import CoreText
import Foundation
import EasyStreamCore

extension BroadcastMetalSpriteBus {
    func lyrioraBitmap(for request: Request) -> Bitmap? {
        let headline = request.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = request.subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let fullScreen = request.lyrioraFullScreen
        if fullScreen, headline.isEmpty, body.isEmpty { return nil }
        let width = 1920
        let layout = Self.lyrioraFrame(fullScreen: fullScreen)
        let height = layout.height
        var data = Data(count: width * height * 4)
        let palette = LyrioraSpritePalette(style: request.lyrioraStyle, opaque: fullScreen)
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
            context.setFillColor(Self.cgColor(hex: palette.plateHex, alpha: palette.plateAlpha))
            if fullScreen {
                context.fill(bounds)
            } else {
                let plate = CGPath(
                    roundedRect: bounds.insetBy(dx: 2, dy: 2),
                    cornerWidth: 28,
                    cornerHeight: 28,
                    transform: nil
                )
                context.addPath(plate)
                context.fillPath()
            }

            if request.lyrioraStyle == .studio {
                context.setFillColor(Self.cgColor(hex: "3DFF8A", alpha: 1))
                let barX: CGFloat = fullScreen ? 0 : 2
                context.fill(CGRect(x: barX, y: fullScreen ? 0 : 24, width: fullScreen ? 18 : 12, height: fullScreen ? CGFloat(height) : CGFloat(height) - 48))
            }
            if request.lyrioraStyle == .liturgical {
                context.setFillColor(Self.cgColor(hex: "E6C36A", alpha: 1))
                let inset: CGFloat = fullScreen ? 96 : 48
                context.fill(CGRect(x: inset, y: CGFloat(height) - (fullScreen ? 48 : 18), width: CGFloat(width) - inset * 2, height: 3))
                context.fill(CGRect(x: inset, y: fullScreen ? 36 : 14, width: CGFloat(width) - inset * 2, height: 3))
            }

            context.translateBy(x: 0, y: CGFloat(height))
            context.scaleBy(x: 1, y: -1)

            let sideInset: CGFloat = fullScreen ? 120 : 72
            let textLeft = sideInset
            let textWidth = CGFloat(width) - sideInset * 2
            let verticalPad: CGFloat = fullScreen ? 96 : 28
            let flowedBody = fullScreen ? body : Self.flowedLine(body)
            let bodyBudget = CGFloat(height) - verticalPad * 2 - (headline.isEmpty ? 0 : 64)
            let bodySize = fittedBodySize(
                flowedBody,
                fontName: palette.bodyFont,
                maxWidth: textWidth,
                maxHeight: max(48, bodyBudget),
                fullScreen: fullScreen,
                reduceMotion: request.reduceMotion
            )
            let headlineSize: CGFloat = fullScreen ? 42 : min(26, bodySize * 0.62)
            let lines = wrappedLines(flowedBody, fontName: palette.bodyFont, size: bodySize, maxWidth: textWidth)
            // Taller than the em box so ascenders are not sliced by the line clip.
            let lineHeight = bodySize * 1.85
            let headlineBlock: CGFloat = headline.isEmpty ? 0 : headlineSize * 1.85 + 8
            let block = headlineBlock + lineHeight * CGFloat(max(lines.count, 1))
            var cursor = max(verticalPad, (CGFloat(height) - block) / 2)
            if !headline.isEmpty {
                Self.drawAligned(
                    headline,
                    hex: palette.headlineHex,
                    size: headlineSize,
                    fontName: palette.headlineFont,
                    in: context,
                    rect: CGRect(x: textLeft, y: cursor, width: textWidth, height: headlineSize * 1.85),
                    center: true,
                    clips: false
                )
                cursor += headlineSize * 1.85 + 8
            }
            for line in lines {
                Self.drawAligned(
                    line,
                    hex: palette.bodyHex,
                    size: bodySize,
                    fontName: palette.bodyFont,
                    in: context,
                    rect: CGRect(x: textLeft, y: cursor, width: textWidth, height: lineHeight),
                    center: true,
                    clips: false
                )
                cursor += lineHeight
            }
        }

        let enter: Float = fullScreen ? 0 : (request.reduceMotion ? 0.2 : 0.4)
        let exit: Float = request.reduceMotion ? 0.2 : 0.35
        let slide: Float = request.reduceMotion || fullScreen ? 0 : 0.12
        return Bitmap(
            rgba: data,
            width: width,
            height: height,
            centerX: fullScreen ? 0.5 : request.centerX,
            centerY: layout.centerY,
            widthFraction: layout.widthFraction,
            heightFraction: layout.heightFraction,
            uniformSquare: false,
            spinDuration: 0,
            pauseDuration: 0,
            scrollUVPerSecond: 0,
            playsSequence: true,
            enterDuration: enter,
            exitDelay: 1_000_000,
            exitDuration: exit,
            slideFraction: slide,
            enterScale: 1,
            slidesVertically: true,
            motionIdentity: fullScreen
                ? "full\u{1}\(headline)\u{1}\(body)\u{1}\(request.lyrioraStyle.rawValue)"
                : "lower\u{1}\(request.lyrioraStyle.rawValue)",
            settlesVisible: true
        )
    }

    /// Full-screen fills the program. The lower third keeps the bitmap aspect of its slot so the plate is not squashed or cropped.
    private static func lyrioraFrame(fullScreen: Bool) -> (height: Int, widthFraction: Float, heightFraction: Float, centerY: Float) {
        if fullScreen {
            return (1080, 1, 1, 0.5)
        }
        let widthFraction: Float = 0.96
        let heightFraction: Float = 0.22
        let slotAspect = (CGFloat(widthFraction) / CGFloat(heightFraction)) * (16.0 / 9.0)
        let height = max(220, Int((1920 / slotAspect).rounded()))
        let centerY = 1 - heightFraction / 2 - 0.012
        return (height, widthFraction, heightFraction, centerY)
    }

    /// Lower thirds ignore Lyriora's line breaks and refill the plate width.
    private static func flowedLine(_ text: String) -> String {
        text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func fittedBodySize(
        _ text: String,
        fontName: String,
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        fullScreen: Bool,
        reduceMotion: Bool
    ) -> CGFloat {
        _ = reduceMotion
        // Lower thirds stay inside the plate. A size that fills the width at 120 pt
        // clips the glyphs against the rounded corners.
        var size: CGFloat = fullScreen ? 72 : 30
        let minimum: CGFloat = fullScreen ? 28 : 20
        while size > minimum {
            let lines = wrappedLines(text, fontName: fontName, size: size, maxWidth: maxWidth)
            let widest = lines.map { Self.lineWidth($0, font: CTFontCreateWithName(fontName as CFString, size, nil)) }.max() ?? 0
            let fitsHeight = CGFloat(max(lines.count, 1)) * size * 1.85 <= maxHeight
            let fitsWidth = widest <= maxWidth * 0.98
            if fitsHeight && fitsWidth { return size }
            size -= 2
        }
        return minimum
    }

    private func wrappedLines(_ text: String, fontName: String, size: CGFloat, maxWidth: CGFloat) -> [String] {
        let font = CTFontCreateWithName(fontName as CFString, size, nil)
        var lines: [String] = []
        for paragraph in text.components(separatedBy: .newlines) {
            let words = paragraph.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
            if words.isEmpty {
                if !paragraph.isEmpty { lines.append(paragraph) }
                continue
            }
            var current = ""
            for word in words {
                let candidate = current.isEmpty ? word : current + " " + word
                if current.isEmpty || Self.lineWidth(candidate, font: font) <= maxWidth {
                    current = candidate
                } else {
                    lines.append(current)
                    current = word
                }
            }
            if !current.isEmpty { lines.append(current) }
        }
        return lines.isEmpty ? [""] : lines
    }

    private static func lineWidth(_ text: String, font: CTFont) -> CGFloat {
        let attributes: [CFString: Any] = [kCTFontAttributeName: font]
        guard let attributed = CFAttributedStringCreate(kCFAllocatorDefault, text as CFString, attributes as CFDictionary) else {
            return 0
        }
        let line = CTLineCreateWithAttributedString(attributed)
        return CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    }
}

private struct LyrioraSpritePalette {
    var plateHex: String
    var plateAlpha: CGFloat
    var headlineHex: String
    var bodyHex: String
    var headlineFont: String
    var bodyFont: String

    init(style: LyrioraVisualStyle, opaque: Bool) {
        switch style {
        case .classic:
            plateHex = "101010"
            plateAlpha = opaque ? 1 : 0.72
            headlineHex = "F2E8D5"
            bodyHex = "FFFFFF"
            headlineFont = "TimesNewRomanPS-BoldMT"
            bodyFont = "TimesNewRomanPSMT"
        case .studio:
            plateHex = "0C1220"
            plateAlpha = opaque ? 1 : 0.9
            headlineHex = "3DFF8A"
            bodyHex = "FFFFFF"
            headlineFont = "HelveticaNeue-CondensedBold"
            bodyFont = "HelveticaNeue-CondensedBold"
        case .liturgical:
            plateHex = "140E08"
            plateAlpha = opaque ? 1 : 0.82
            headlineHex = "E6C36A"
            bodyHex = "F7F1E3"
            headlineFont = "Palatino-Bold"
            bodyFont = "Palatino-Roman"
        }
    }
}
