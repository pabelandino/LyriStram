import CoreGraphics
import CoreText
import Foundation

extension BroadcastMetalSpriteBus {
    func timepieceLabel(_ request: Request, now: Date, countdownStart: Date?) -> String {
        switch request.kind {
        case .clock:
            let time = clockString(request, now: now)
            guard request.clockShowsDate else { return time }
            return time + "\n" + dateString(now)
        case .countdown:
            return countdownString(request, now: now, countdownStart: countdownStart)
        default:
            return ""
        }
    }

    func timepieceBitmap(_ request: Request, now: Date, countdownStart: Date?) -> Bitmap? {
        let label = timepieceLabel(request, now: now, countdownStart: countdownStart)
        let lines = label.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let height = request.kind == .countdown ? 320 : 180
        let slotAspect = CGFloat(request.widthFraction) / CGFloat(max(request.heightFraction, 0.01)) * (16 / 9)
        let width = max(height, Int((CGFloat(height) * slotAspect).rounded()))
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
            if request.kind == .clock {
                if request.clockShowsBackground {
                    drawClockPlate(in: bounds, context: context)
                }
                drawClockLines(
                    lines,
                    in: clockTextRect(in: bounds),
                    fontName: timepieceFont(request),
                    context: context
                )
            } else {
                drawFittedLine(
                    lines.first ?? "00:00",
                    hex: request.accentHex,
                    fontName: timepieceFont(request),
                    in: context,
                    rect: bounds.insetBy(dx: bounds.width * 0.06, dy: bounds.height * 0.08)
                )
            }
            return true
        }
        guard drew else { return nil }
        return Bitmap(
            rgba: data,
            width: width,
            height: height,
            centerX: request.centerX,
            centerY: request.centerY,
            widthFraction: request.widthFraction * clockSpriteScale(request),
            heightFraction: request.heightFraction * clockSpriteScale(request),
            uniformSquare: false,
            spinDuration: 0,
            pauseDuration: 0,
            scrollUVPerSecond: 0,
            sourceID: request.sourceID
        )
    }
}

private func drawClockPlate(in bounds: CGRect, context: CGContext) {
    let radius = bounds.height * 0.16
    let path = CGPath(roundedRect: bounds, cornerWidth: radius, cornerHeight: radius, transform: nil)
    context.setFillColor(BroadcastMetalSpriteBus.cgColor(hex: "000000", alpha: 0.62))
    context.addPath(path)
    context.fillPath()
}

/// Time sits a little left of center so the plate keeps breathing room on the right.
private func clockTextRect(in bounds: CGRect) -> CGRect {
    CGRect(
        x: bounds.width * 0.035,
        y: bounds.height * 0.12,
        width: bounds.width * 0.84,
        height: bounds.height * 0.76
    )
}

/// 28 pt keeps the current clock. Larger values grow the whole graphic; the cap keeps it on screen.
private func clockSpriteScale(_ request: BroadcastMetalSpriteBus.Request) -> Float {
    guard request.kind == .clock else { return 1 }
    let requested = min(max(request.titleFontScale, 0.4), 2.8)
    let halfWidth = max(request.widthFraction * 0.5, 0.01)
    let halfHeight = max(request.heightFraction * 0.5, 0.01)
    let roomX = min(request.centerX, 1 - request.centerX) / halfWidth
    let roomY = min(request.centerY, 1 - request.centerY) / halfHeight
    return min(requested, max(min(roomX, roomY), 0.4))
}

private func drawClockLines(
    _ lines: [String],
    in bounds: CGRect,
    fontName: String,
    context: CGContext
) {
    let time = lines.first ?? ""
    let date = lines.count > 1 ? lines[1] : nil
    if let date {
        let timeRect = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.height * 0.62)
        let dateRect = CGRect(x: bounds.minX, y: timeRect.maxY, width: bounds.width, height: bounds.height - timeRect.height)
        drawFittedLine(time, hex: "FFFFFF", fontName: fontName, in: context, rect: timeRect)
        drawFittedLine(date, hex: "E6E6E6", fontName: fontName, in: context, rect: dateRect)
    } else {
        drawFittedLine(time, hex: "FFFFFF", fontName: fontName, in: context, rect: bounds)
    }
}

/// Fits the whole glyph ink inside `rect`. In this y-down context, Core Text extends glyphs toward larger y.
private func drawFittedLine(
    _ text: String,
    hex: String,
    fontName: String,
    in context: CGContext,
    rect: CGRect
) {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, rect.width > 8, rect.height > 8 else { return }
    let probeSize: CGFloat = 100
    let color = BroadcastMetalSpriteBus.cgColor(hex: hex, alpha: 1)
    guard let probeLine = timepieceLine(trimmed, fontName: fontName, size: probeSize, color: color) else { return }
    context.textPosition = .zero
    let probeImage = CTLineGetImageBounds(probeLine, context)
    guard probeImage.width > 0.5, probeImage.height > 0.5 else { return }
    let scale = min(rect.width / probeImage.width, rect.height / probeImage.height)
    let fontSize = max(8, probeSize * scale)
    guard let line = timepieceLine(trimmed, fontName: fontName, size: fontSize, color: color) else { return }
    context.textPosition = .zero
    let image = CTLineGetImageBounds(line, context)
    let baseline = rect.midY - (image.minY + image.height / 2)
    let x = rect.midX - (image.minX + image.width / 2)
    context.saveGState()
    context.textMatrix = .identity
    context.textPosition = CGPoint(x: x, y: baseline)
    CTLineDraw(line, context)
    context.restoreGState()
}

private func timepieceLine(_ text: String, fontName: String, size: CGFloat, color: CGColor) -> CTLine? {
    let font = CTFontCreateWithName(fontName as CFString, size, nil)
    let attributes: [CFString: Any] = [
        kCTFontAttributeName: font,
        kCTForegroundColorAttributeName: color
    ]
    guard let attributed = CFAttributedStringCreate(kCFAllocatorDefault, text as CFString, attributes as CFDictionary) else {
        return nil
    }
    return CTLineCreateWithAttributedString(attributed)
}

private func timepieceFont(_ request: BroadcastMetalSpriteBus.Request) -> String {
    switch request.titleFont {
    case .monospaced, .system, .boldDisplay:
        "Menlo-Bold"
    case .serif:
        "Georgia-Bold"
    case .condensed:
        "HelveticaNeue-CondensedBold"
    case .rounded:
        "Avenir-Heavy"
    }
}

private func clockString(_ request: BroadcastMetalSpriteBus.Request, now: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    if request.clockUse24Hour {
        formatter.dateFormat = request.clockShowsSeconds ? "HH:mm:ss" : "HH:mm"
    } else {
        formatter.dateFormat = request.clockShowsSeconds ? "h:mm:ss a" : "h:mm a"
    }
    return formatter.string(from: now)
}

private func dateString(_ now: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: now)
}

private func countdownString(
    _ request: BroadcastMetalSpriteBus.Request,
    now: Date,
    countdownStart: Date?
) -> String {
    let remaining: Int
    if let target = request.countdownTarget {
        remaining = max(0, Int(target.timeIntervalSince(now).rounded(.down)))
    } else {
        let elapsed = Int(now.timeIntervalSince(countdownStart ?? now).rounded(.down))
        remaining = max(0, request.countdownSeconds - elapsed)
    }
    let minutes = remaining / 60
    let seconds = remaining % 60
    return String(format: "%02d:%02d", minutes, seconds)
}
