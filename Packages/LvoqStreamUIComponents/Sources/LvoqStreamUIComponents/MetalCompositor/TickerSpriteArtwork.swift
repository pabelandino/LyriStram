import CoreGraphics
import CoreText
import Foundation

extension BroadcastMetalSpriteBus {
    func tickerPieces(_ request: Request) -> [Bitmap] {
        [tickerBar(request), tickerStrip(request)].compactMap { $0 }
    }
}

private func tickerBar(_ request: BroadcastMetalSpriteBus.Request) -> BroadcastMetalSpriteBus.Bitmap? {
    let width = 480
    let height = 64
    var data = Data(count: width * height * 4)
    let drew = data.withUnsafeMutableBytes { raw -> Bool in
        guard let context = CGContext(
            data: raw.baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return false }
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        let bounds = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        if request.tickerUsesGradient {
            BroadcastMetalSpriteBus.drawLinearGradient(
                in: context,
                bounds: bounds,
                startHex: request.tickerGradientStartHex,
                endHex: request.tickerGradientEndHex,
                angle: request.gradientAngle
            )
        } else {
            context.setFillColor(BroadcastMetalSpriteBus.cgColor(hex: request.tickerBackgroundHex, alpha: 1))
            context.fill(bounds)
        }
        return true
    }
    guard drew else { return nil }
    return tickerBitmap(data: data, width: width, height: height, request: request, scrollPointsPerSecond: 0, matchesTextScale: false)
}

private func tickerStrip(_ request: BroadcastMetalSpriteBus.Request) -> BroadcastMetalSpriteBus.Bitmap? {
    let text = tickerRepeatUnit(request.title)
    let height = 80
    let fontSize = floor(CGFloat(height) * 0.58)
    let font = CTFontCreateWithName("HelveticaNeue-CondensedBold" as CFString, fontSize, nil)
    let attributes: [CFString: Any] = [
        kCTFontAttributeName: font,
        kCTForegroundColorAttributeName: BroadcastMetalSpriteBus.cgColor(hex: request.textHex, alpha: 1)
    ]
    guard let attributed = CFAttributedStringCreate(
        kCFAllocatorDefault,
        text as CFString,
        attributes as CFDictionary
    ) else { return nil }
    let line = CTLineCreateWithAttributedString(attributed)
    let loop = max(Int(ceil(CTLineGetTypographicBounds(line, nil, nil, nil))), 1)
    let width = loop * 2
    var data = Data(count: width * height * 4)
    let drew = data.withUnsafeMutableBytes { raw -> Bool in
        guard let context = CGContext(
            data: raw.baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return false }
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        let baseline = tickerBaseline(line, height: CGFloat(height), in: context)
        for copy in 0..<2 {
            context.textPosition = CGPoint(x: CGFloat(copy * loop), y: baseline)
            CTLineDraw(line, context)
        }
        return true
    }
    guard drew else { return nil }
    return tickerBitmap(
        data: data,
        width: width,
        height: height,
        request: request,
        scrollPointsPerSecond: Float(max(request.tickerSpeed, 20)),
        matchesTextScale: true
    )
}

private func tickerBitmap(
    data: Data,
    width: Int,
    height: Int,
    request: BroadcastMetalSpriteBus.Request,
    scrollPointsPerSecond: Float,
    matchesTextScale: Bool
) -> BroadcastMetalSpriteBus.Bitmap {
    BroadcastMetalSpriteBus.Bitmap(
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
        scrollUVPerSecond: scrollPointsPerSecond,
        playsSequence: true,
        enterDelay: 0,
        enterDuration: 0.45,
        exitDelay: 10_000_000,
        exitDuration: 0.42,
        slideFraction: 1.2,
        enterScale: 1,
        sourceID: request.sourceID,
        slidesVertically: true,
        matchesTextScale: matchesTextScale
    )
}

private func tickerRepeatUnit(_ title: String) -> String {
    let line = title.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !line.isEmpty else { return " " }
    return line.hasSuffix(" ") ? line : line + " "
}

/// Centers the drawn ink in the band. Capitals have no descender, so the em box sits high.
private func tickerBaseline(_ line: CTLine, height: CGFloat, in context: CGContext) -> CGFloat {
    context.textPosition = .zero
    let ink = CTLineGetImageBounds(line, context)
    let inkHeight = ink.height
    guard inkHeight > 0.5 else {
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        CTLineGetTypographicBounds(line, &ascent, &descent, nil)
        return height / 2 + (ascent - descent) / 2
    }
    return height / 2 - (ink.minY + ink.maxY) / 2
}
