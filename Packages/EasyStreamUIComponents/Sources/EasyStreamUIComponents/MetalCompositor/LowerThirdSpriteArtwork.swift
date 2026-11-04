import CoreGraphics
import Foundation
import EasyStreamCore

extension BroadcastMetalSpriteBus {
    func lowerThirdPieces(_ request: Request) -> [Bitmap] {
        let layoutPieces = LowerThirdLayout.pieces(
            style: request.style,
            hasThirdLine: !request.thirdLine.isEmpty
        )
        let sequence = LowerThirdSequence.make(
            style: request.style,
            hasThirdLine: !request.thirdLine.isEmpty,
            animateIn: request.animateIn,
            hold: request.hold,
            animateOut: request.animateOut
        )
        let fitted = LowerThirdLayout.fittedFractions(
            slotWidth: Double(request.widthFraction),
            slotHeight: Double(request.heightFraction)
        )
        let left = Double(request.centerX) - fitted.width / 2
        let top = Double(request.centerY) - fitted.height / 2
        let logo = request.logoPath.flatMap(Self.loadCGImage)

        return layoutPieces.compactMap { piece in
            guard let pixels = renderPiece(piece, request: request, logo: logo) else { return nil }
            let cue = piece.kind == .logo
                ? sequence.logo
                : sequence.bars[min(max(piece.barIndex, 0), max(sequence.bars.count - 1, 0))]
            let centerX = left + ((piece.frame.x + piece.frame.width / 2) / LowerThirdLayout.width) * fitted.width
            let centerY = top + ((piece.frame.y + piece.frame.height / 2) / LowerThirdLayout.height) * fitted.height
            return Bitmap(
                rgba: pixels.data,
                width: pixels.width,
                height: pixels.height,
                centerX: Float(centerX),
                centerY: Float(centerY),
                widthFraction: Float((piece.frame.width / LowerThirdLayout.width) * fitted.width),
                heightFraction: Float((piece.frame.height / LowerThirdLayout.height) * fitted.height),
                uniformSquare: false,
                spinDuration: 0,
                pauseDuration: 0,
                scrollUVPerSecond: 0,
                playsSequence: request.playsSequence,
                enterDelay: Float(cue.enterDelay),
                enterDuration: Float(cue.enterDuration),
                exitDelay: Float(cue.exitDelay),
                exitDuration: Float(cue.exitDuration),
                slideFraction: Float(cue.slideFraction),
                enterScale: Float(cue.enterScale)
            )
        }
    }
}

private func renderPiece(
    _ piece: LowerThirdPiece,
    request: BroadcastMetalSpriteBus.Request,
    logo: CGImage?
) -> (data: Data, width: Int, height: Int)? {
    let width = max(2, Int(piece.frame.width.rounded()))
    let height = max(2, Int(piece.frame.height.rounded()))
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
        context.translateBy(x: -CGFloat(piece.frame.x), y: -CGFloat(piece.frame.y))
        drawPiece(piece, request: request, logo: logo, in: context)
        return true
    }
    return drew ? (data, width, height) : nil
}

private func drawPiece(
    _ piece: LowerThirdPiece,
    request: BroadcastMetalSpriteBus.Request,
    logo: CGImage?,
    in context: CGContext
) {
    let rect = piece.frame.rect
    switch piece.kind {
    case .logo:
        if request.style == .guest {
            drawGuestPortrait(rect, request: request, logo: logo, in: context)
        } else if request.style == .titlePlate {
            drawTitleSquare(rect, request: request, logo: logo, in: context)
        } else {
            drawAngularPlate(rect, request: request, logo: logo, in: context)
        }
    case .lightBar:
        drawSlantedBar(
            rect,
            text: request.title,
            textHex: LowerThirdContrast.textHex(request.textHex, on: "FFFFFF"),
            fillHex: "FFFFFF",
            gradientEnd: nil,
            fontName: fontName(request.titleFont),
            size: rect.height * 0.46 * CGFloat(max(request.titleFontScale, 0.45)),
            in: context
        )
    case .darkBar:
        drawSlantedBar(
            rect,
            text: request.subtitle,
            textHex: LowerThirdContrast.textHex(request.subtitleHex, on: "2C2C2E"),
            fillHex: "2C2C2E",
            gradientEnd: nil,
            fontName: fontName(request.subtitleFont),
            size: rect.height * 0.40 * CGFloat(max(request.subtitleFontScale, 0.7)),
            in: context
        )
    case .accentBar:
        drawSlantedBar(
            rect,
            text: request.thirdLine,
            textHex: LowerThirdContrast.textHex(request.textHex, on: request.accentHex),
            fillHex: request.accentHex,
            gradientEnd: request.gradientEndHex,
            angle: request.gradientAngle,
            fontName: fontName(request.titleFont),
            size: rect.height * 0.46 * CGFloat(max(request.titleFontScale, 0.45)),
            in: context
        )
    case .titleBlock:
        drawTitleBlock(rect, request: request, in: context)
    case .nameBlock:
        drawNameBlock(rect, request: request, in: context)
    }
}

private func drawAngularPlate(_ rect: CGRect, request: BroadcastMetalSpriteBus.Request, logo: CGImage?, in context: CGContext) {
    let fold = platePath(in: rect.offsetBy(dx: 8, dy: 10))
    context.setFillColor(BroadcastMetalSpriteBus.cgColor(hex: "000000", alpha: 0.4))
    context.addPath(fold)
    context.fillPath()

    let plate = platePath(in: rect)
    fillAccent(plate, hex: request.accentHex, gradientEnd: request.gradientEndHex, bounds: rect, angle: request.gradientAngle, in: context)

    if let logo {
        let inner = rect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.16)
        context.saveGState()
        context.addPath(plate)
        context.clip()
        drawImage(logo, in: aspectFill(logo, in: inner), context: context)
        context.restoreGState()
    }
}

private func drawTitleSquare(_ rect: CGRect, request: BroadcastMetalSpriteBus.Request, logo: CGImage?, in context: CGContext) {
    fillAccent(CGPath(rect: rect, transform: nil), hex: request.accentHex, gradientEnd: request.gradientEndHex, bounds: rect, angle: request.gradientAngle, in: context)
    let labelTop = rect.minY + rect.height * 0.12
    if let logo {
        let slot = airFlipped(
            CGRect(x: rect.minX + 16, y: labelTop, width: rect.width * 0.42, height: rect.height * 0.28),
            within: rect
        )
        drawImage(logo, in: aspectFit(logo, in: slot), context: context)
    }
    let textRect = airFlipped(
        CGRect(x: rect.minX + 14, y: labelTop, width: rect.width - 28, height: rect.height * 0.62),
        within: rect
    )
    BroadcastMetalSpriteBus.drawAligned(
        (request.subtitle.isEmpty ? request.title : request.subtitle).uppercased(),
        hex: LowerThirdContrast.textHex(request.subtitleHex, on: request.accentHex),
        size: rect.height * 0.2 * CGFloat(max(request.subtitleFontScale, 0.7)),
        fontName: fontName(request.subtitleFont),
        in: context,
        rect: textRect,
        center: false
    )
}

private func drawGuestPortrait(_ rect: CGRect, request: BroadcastMetalSpriteBus.Request, logo: CGImage?, in context: CGContext) {
    let line = max(4, rect.width * 0.035)
    let ring = rect.insetBy(dx: line / 2, dy: line / 2)
    context.setStrokeColor(BroadcastMetalSpriteBus.cgColor(hex: request.accentHex, alpha: 1))
    context.setLineWidth(line)
    context.setLineDash(phase: 0, lengths: [rect.width * 0.045, rect.width * 0.03])
    context.strokeEllipse(in: ring)
    context.setLineDash(phase: 0, lengths: [])

    let photo = rect.insetBy(dx: rect.width * 0.07, dy: rect.height * 0.07)
    context.saveGState()
    context.addEllipse(in: photo)
    context.clip()
    if let logo {
        drawImage(logo, in: aspectFill(logo, in: photo), context: context)
    } else {
        context.setFillColor(BroadcastMetalSpriteBus.cgColor(hex: "1E2420", alpha: 1))
        context.fill(photo)
    }
    context.restoreGState()
}

private func drawTitleBlock(_ rect: CGRect, request: BroadcastMetalSpriteBus.Request, in context: CGContext) {
    let ruleHeight = max(4, rect.height * 0.055)
    let rule = airFlipped(
        CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: ruleHeight),
        within: rect
    )
    context.setFillColor(BroadcastMetalSpriteBus.cgColor(hex: "FFFFFF", alpha: 1))
    context.fill(rule)
    let textRect = airFlipped(
        CGRect(
            x: rect.minX,
            y: rect.minY + ruleHeight + 10,
            width: rect.width,
            height: rect.height - ruleHeight - 16
        ),
        within: rect
    )
    BroadcastMetalSpriteBus.drawAligned(
        request.title.uppercased(),
        hex: request.textHex,
        size: rect.height * 0.42 * CGFloat(max(request.titleFontScale, 0.45)),
        fontName: fontName(request.titleFont),
        in: context,
        rect: textRect,
        center: false
    )
}

private func drawNameBlock(_ rect: CGRect, request: BroadcastMetalSpriteBus.Request, in context: CGContext) {
    let kickerHeight = rect.height * 0.26
    let kicker = airFlipped(
        CGRect(x: rect.minX + 18, y: rect.minY, width: rect.width - 28, height: kickerHeight),
        within: rect
    )
    BroadcastMetalSpriteBus.drawAligned(
        request.subtitle.uppercased(),
        hex: request.subtitleHex,
        size: kickerHeight * 0.5 * CGFloat(max(request.subtitleFontScale, 0.7)),
        fontName: fontName(request.subtitleFont),
        in: context,
        rect: kicker,
        center: false
    )
    let bar = airFlipped(
        CGRect(x: rect.minX, y: rect.minY + kickerHeight, width: rect.width, height: rect.height - kickerHeight),
        within: rect
    )
    fillAccent(CGPath(rect: bar, transform: nil), hex: request.accentHex, gradientEnd: request.gradientEndHex, bounds: bar, angle: request.gradientAngle, in: context)
    BroadcastMetalSpriteBus.drawAligned(
        request.title,
        hex: LowerThirdContrast.textHex(request.textHex, on: request.accentHex),
        size: bar.height * 0.42 * CGFloat(max(request.titleFontScale, 0.45)),
        fontName: fontName(request.titleFont),
        in: context,
        rect: bar.insetBy(dx: 28, dy: 10),
        center: false
    )
}

private func airFlipped(_ rect: CGRect, within piece: CGRect) -> CGRect {
    CGRect(
        x: rect.minX,
        y: piece.minY + (piece.maxY - rect.maxY),
        width: rect.width,
        height: rect.height
    )
}

private func drawSlantedBar(
    _ rect: CGRect,
    text: String,
    textHex: String,
    fillHex: String,
    gradientEnd: String?,
    angle: Double = 0,
    fontName: String,
    size: CGFloat,
    in context: CGContext
) {
    let path = slantedPath(in: rect)
    fillAccent(path, hex: fillHex, gradientEnd: gradientEnd, bounds: rect, angle: angle, in: context)
    let skew = min(rect.height * 0.72, 36)
    let textRect = CGRect(
        x: rect.minX + skew + 18,
        y: rect.minY,
        width: max(20, rect.width - skew * 2 - 36),
        height: rect.height
    )
    BroadcastMetalSpriteBus.drawAligned(
        text,
        hex: textHex,
        size: size,
        fontName: fontName,
        in: context,
        rect: textRect,
        center: false
    )
}

private func fillAccent(
    _ path: CGPath,
    hex: String,
    gradientEnd: String?,
    bounds: CGRect,
    angle: Double = 0,
    in context: CGContext
) {
    context.saveGState()
    context.addPath(path)
    if let gradientEnd {
        context.clip()
        BroadcastMetalSpriteBus.drawLinearGradient(
            in: context,
            bounds: bounds,
            startHex: hex,
            endHex: gradientEnd,
            angle: angle
        )
    } else {
        context.setFillColor(BroadcastMetalSpriteBus.cgColor(hex: hex, alpha: 1))
        context.fillPath()
    }
    context.restoreGState()
}

private func platePath(in rect: CGRect) -> CGPath {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: rect.minX + rect.width * 0.06, y: rect.minY + rect.height * 0.16))
    path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.70, y: rect.minY + rect.height * 0.05))
    path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.03, y: rect.midY))
    path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.70, y: rect.maxY - rect.height * 0.05))
    path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.06, y: rect.maxY - rect.height * 0.16))
    path.closeSubpath()
    return path
}

private func slantedPath(in rect: CGRect) -> CGPath {
    let skew = min(rect.height * 0.72, 36)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: rect.minX + skew, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - skew, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.closeSubpath()
    return path
}

private func drawImage(_ image: CGImage, in rect: CGRect, context: CGContext) {
    context.draw(image, in: rect)
}

private func aspectFit(_ image: CGImage, in rect: CGRect) -> CGRect {
    let scale = min(rect.width / CGFloat(image.width), rect.height / CGFloat(image.height))
    let width = CGFloat(image.width) * scale
    let height = CGFloat(image.height) * scale
    return CGRect(x: rect.midX - width / 2, y: rect.midY - height / 2, width: width, height: height)
}

private func aspectFill(_ image: CGImage, in rect: CGRect) -> CGRect {
    let scale = max(rect.width / CGFloat(image.width), rect.height / CGFloat(image.height))
    let width = CGFloat(image.width) * scale
    let height = CGFloat(image.height) * scale
    return CGRect(x: rect.midX - width / 2, y: rect.midY - height / 2, width: width, height: height)
}

private func fontName(_ preset: BroadcastFontPreset) -> String {
    switch preset {
    case .system: "Helvetica-Bold"
    case .rounded, .boldDisplay: "Avenir-Heavy"
    case .serif: "Georgia-Bold"
    case .monospaced: "Menlo-Bold"
    case .condensed: "HelveticaNeue-CondensedBold"
    }
}
