import SwiftUI
import EasyStreamCore
import CoreText
import QuartzCore

#if os(macOS)
import AppKit

struct TickerCoreMotionView: NSViewRepresentable {
    var text: String
    var speed: Double
    var font: NSFont
    var textColor: CGColor
    var backgroundColor: CGColor?
    var gradientStart: CGColor?
    var gradientEnd: CGColor?
    var gradientAngle: Double

    func makeNSView(context: Context) -> TickerMotionCanvasNSView {
        let view = TickerMotionCanvasNSView()
        view.configure(
            text: text,
            speed: speed,
            font: font,
            textColor: textColor,
            backgroundColor: backgroundColor,
            gradientStart: gradientStart,
            gradientEnd: gradientEnd,
            gradientAngle: gradientAngle
        )
        return view
    }

    func updateNSView(_ view: TickerMotionCanvasNSView, context: Context) {
        view.configure(
            text: text,
            speed: speed,
            font: font,
            textColor: textColor,
            backgroundColor: backgroundColor,
            gradientStart: gradientStart,
            gradientEnd: gradientEnd,
            gradientAngle: gradientAngle
        )
    }
}

final class TickerMotionCanvasNSView: NSView {
    private let gradientLayer = CAGradientLayer()
    private let strip = CALayer()
    private var signature = ""
    private var pending: (String, Double, NSFont, CGColor, CGColor?, CGColor?, CGColor?, Double)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.cornerRadius = 0
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer?.addSublayer(gradientLayer)
        layer?.addSublayer(strip)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layout() {
        super.layout()
        gradientLayer.frame = bounds
        guard let pending, bounds.width > 1 else { return }
        configure(
            text: pending.0,
            speed: pending.1,
            font: pending.2,
            textColor: pending.3,
            backgroundColor: pending.4,
            gradientStart: pending.5,
            gradientEnd: pending.6,
            gradientAngle: pending.7
        )
    }

    func configure(
        text: String,
        speed: Double,
        font: NSFont,
        textColor: CGColor,
        backgroundColor: CGColor?,
        gradientStart: CGColor?,
        gradientEnd: CGColor?,
        gradientAngle: Double
    ) {
        let fitted = TickerMotionGraphics.bandFont(font, height: bounds.height)
        pending = (text, speed, font, textColor, backgroundColor, gradientStart, gradientEnd, gradientAngle)
        applyBackground(color: backgroundColor, gradientStart: gradientStart, gradientEnd: gradientEnd, angle: gradientAngle)
        let next = "\(text)|\(speed)|\(fitted.pointSize)|\(bounds.width)|\(bounds.height)|\(TickerMotionGraphics.colorToken(textColor))"
        guard next != signature, bounds.width > 1, bounds.height > 1 else { return }
        signature = next
        let rendered = TickerMotionGraphics.strip(text: text, font: fitted, color: textColor, height: bounds.height)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        strip.contentsGravity = .resize
        strip.contents = rendered.image
        strip.contentsScale = rendered.image.width > 0 ? CGFloat(rendered.image.width) / rendered.width : 1
        strip.frame = CGRect(x: 0, y: 0, width: rendered.width, height: bounds.height)
        CATransaction.commit()
        TickerMotionGraphics.scroll(strip, distance: rendered.loopWidth, speed: speed)
    }

    private func applyBackground(color: CGColor?, gradientStart: CGColor?, gradientEnd: CGColor?, angle: Double) {
        gradientLayer.frame = bounds
        if let gradientStart, let gradientEnd {
            let radians = angle * .pi / 180
            let dx = cos(radians) * 0.5
            let dy = sin(radians) * 0.5
            gradientLayer.isHidden = false
            gradientLayer.colors = [gradientStart, gradientEnd]
            gradientLayer.startPoint = CGPoint(x: 0.5 - dx, y: 0.5 - dy)
            gradientLayer.endPoint = CGPoint(x: 0.5 + dx, y: 0.5 + dy)
            layer?.backgroundColor = nil
        } else {
            gradientLayer.isHidden = true
            layer?.backgroundColor = color
        }
        layer?.cornerRadius = 0
    }
}
#else
import UIKit

struct TickerCoreMotionView: UIViewRepresentable {
    var text: String
    var speed: Double
    var font: UIFont
    var textColor: CGColor
    var backgroundColor: CGColor?
    var gradientStart: CGColor?
    var gradientEnd: CGColor?
    var gradientAngle: Double

    func makeUIView(context: Context) -> TickerMotionCanvasUIView {
        let view = TickerMotionCanvasUIView()
        view.configure(
            text: text,
            speed: speed,
            font: font,
            textColor: textColor,
            backgroundColor: backgroundColor,
            gradientStart: gradientStart,
            gradientEnd: gradientEnd,
            gradientAngle: gradientAngle
        )
        return view
    }

    func updateUIView(_ view: TickerMotionCanvasUIView, context: Context) {
        view.configure(
            text: text,
            speed: speed,
            font: font,
            textColor: textColor,
            backgroundColor: backgroundColor,
            gradientStart: gradientStart,
            gradientEnd: gradientEnd,
            gradientAngle: gradientAngle
        )
    }
}

final class TickerMotionCanvasUIView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let strip = CALayer()
    private var signature = ""
    private var pending: (String, Double, UIFont, CGColor, CGColor?, CGColor?, CGColor?, Double)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        layer.cornerRadius = 0
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
        layer.addSublayer(strip)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        guard let pending, bounds.width > 1 else { return }
        configure(
            text: pending.0,
            speed: pending.1,
            font: pending.2,
            textColor: pending.3,
            backgroundColor: pending.4,
            gradientStart: pending.5,
            gradientEnd: pending.6,
            gradientAngle: pending.7
        )
    }

    func configure(
        text: String,
        speed: Double,
        font: UIFont,
        textColor: CGColor,
        backgroundColor: CGColor?,
        gradientStart: CGColor?,
        gradientEnd: CGColor?,
        gradientAngle: Double
    ) {
        let fitted = TickerMotionGraphics.bandFont(font, height: bounds.height)
        pending = (text, speed, font, textColor, backgroundColor, gradientStart, gradientEnd, gradientAngle)
        applyBackground(color: backgroundColor, gradientStart: gradientStart, gradientEnd: gradientEnd, angle: gradientAngle)
        let next = "\(text)|\(speed)|\(fitted.pointSize)|\(bounds.width)|\(bounds.height)|\(TickerMotionGraphics.colorToken(textColor))"
        guard next != signature, bounds.width > 1, bounds.height > 1 else { return }
        signature = next
        let rendered = TickerMotionGraphics.strip(text: text, font: fitted, color: textColor, height: bounds.height)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        strip.contentsGravity = .resize
        strip.contents = rendered.image
        strip.contentsScale = rendered.image.width > 0 ? CGFloat(rendered.image.width) / rendered.width : 1
        strip.frame = CGRect(x: 0, y: 0, width: rendered.width, height: bounds.height)
        CATransaction.commit()
        TickerMotionGraphics.scroll(strip, distance: rendered.loopWidth, speed: speed)
    }

    private func applyBackground(color: CGColor?, gradientStart: CGColor?, gradientEnd: CGColor?, angle: Double) {
        gradientLayer.frame = bounds
        if let gradientStart, let gradientEnd {
            let radians = angle * .pi / 180
            let dx = cos(radians) * 0.5
            let dy = sin(radians) * 0.5
            gradientLayer.isHidden = false
            gradientLayer.colors = [gradientStart, gradientEnd]
            gradientLayer.startPoint = CGPoint(x: 0.5 - dx, y: 0.5 - dy)
            gradientLayer.endPoint = CGPoint(x: 0.5 + dx, y: 0.5 + dy)
            layer.backgroundColor = nil
        } else {
            gradientLayer.isHidden = true
            layer.backgroundColor = color
        }
        layer.cornerRadius = 0
    }
}
#endif

enum TickerMotionGraphics {
    struct Strip {
        let image: CGImage
        let width: CGFloat
        let loopWidth: CGFloat
    }

    static func colorToken(_ color: CGColor) -> String {
        (color.components ?? []).map { String(format: "%.3f", $0) }.joined(separator: ",")
    }

    static func scroll(_ layer: CALayer, distance: CGFloat, speed: Double) {
        layer.removeAnimation(forKey: "scroll")
        let pointsPerSecond = max(20, speed)
        let travel = max(distance, 1)
        let move = CABasicAnimation(keyPath: "transform.translation.x")
        move.fromValue = 0
        move.toValue = -travel
        move.duration = CFTimeInterval(travel / pointsPerSecond)
        move.timingFunction = CAMediaTimingFunction(name: .linear)
        move.repeatCount = .infinity
        move.isRemovedOnCompletion = false
        layer.add(move, forKey: "scroll")
    }

#if os(macOS)
    static func bandFont(_ font: NSFont, height: CGFloat) -> NSFont {
        font.withSize(max(13, floor(height * 0.62)))
    }
#else
    static func bandFont(_ font: UIFont, height: CGFloat) -> UIFont {
        font.withSize(max(13, floor(height * 0.62)))
    }
#endif

#if os(macOS)
    static func strip(text: String, font: NSFont, color: CGColor, height: CGFloat) -> Strip {
        let line = crawlLine(text: text, fontName: font.fontName, size: font.pointSize, color: color)
        let loop = max(ceil(CTLineGetTypographicBounds(line, nil, nil, nil)), 1)
        let width = loop * 2
        let image = NSImage(size: NSSize(width: width, height: height), flipped: false) { rect in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            let baseline = inkBaseline(line, height: rect.height, in: context)
            drawLoop(line, baseline: baseline, loop: loop, in: context)
            return true
        }
        var proposed = CGRect(origin: .zero, size: image.size)
        let cg = image.cgImage(forProposedRect: &proposed, context: nil, hints: nil)
        return Strip(image: cg ?? emptyImage(width: width, height: height), width: width, loopWidth: loop)
    }
#else
    static func strip(text: String, font: UIFont, color: CGColor, height: CGFloat) -> Strip {
        let line = crawlLine(text: text, fontName: font.fontName, size: font.pointSize, color: color)
        let loop = max(ceil(CTLineGetTypographicBounds(line, nil, nil, nil)), 1)
        let width = loop * 2
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        let image = renderer.image { rendererContext in
            let context = rendererContext.cgContext
            context.translateBy(x: 0, y: height)
            context.scaleBy(x: 1, y: -1)
            let baseline = inkBaseline(line, height: height, in: context)
            drawLoop(line, baseline: baseline, loop: loop, in: context)
        }
        return Strip(image: image.cgImage ?? emptyImage(width: width, height: height), width: width, loopWidth: loop)
    }
#endif

    private static func crawlLine(text: String, fontName: String, size: CGFloat, color: CGColor) -> CTLine {
        let font = CTFontCreateWithName(fontName as CFString, size, nil)
        let attributes: [CFString: Any] = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: color
        ]
        let attributed = CFAttributedStringCreate(
            kCFAllocatorDefault,
            text as CFString,
            attributes as CFDictionary
        )
        return CTLineCreateWithAttributedString(attributed!)
    }

    private static func drawLoop(_ line: CTLine, baseline: CGFloat, loop: CGFloat, in context: CGContext) {
        for copy in 0..<2 {
            context.textPosition = CGPoint(x: CGFloat(copy) * loop, y: baseline)
            CTLineDraw(line, context)
        }
    }

    /// Centers the painted glyphs. An em-box center leaves capitals sitting high.
    private static func inkBaseline(_ line: CTLine, height: CGFloat, in context: CGContext) -> CGFloat {
        context.textPosition = .zero
        let ink = CTLineGetImageBounds(line, context)
        guard ink.height > 0.5 else {
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            CTLineGetTypographicBounds(line, &ascent, &descent, nil)
            return height / 2 - (ascent - descent) / 2
        }
        return height / 2 - (ink.minY + ink.maxY) / 2
    }

    private static func emptyImage(width: CGFloat, height: CGFloat) -> CGImage {
        let context = CGContext(
            data: nil,
            width: max(Int(width), 1),
            height: max(Int(height), 1),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        return context?.makeImage() ?? CGContext(
            data: nil,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!.makeImage()!
    }
}
