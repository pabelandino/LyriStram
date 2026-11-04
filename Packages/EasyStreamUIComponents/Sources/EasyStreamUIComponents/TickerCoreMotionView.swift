import SwiftUI
import EasyStreamCore
import QuartzCore

#if os(macOS)
import AppKit

struct TickerCoreMotionView: NSViewRepresentable {
    var text: String
    var speed: Double
    var font: NSFont
    var textColor: CGColor
    var backgroundColor: CGColor

    func makeNSView(context: Context) -> TickerMotionCanvasNSView {
        let view = TickerMotionCanvasNSView()
        view.configure(text: text, speed: speed, font: font, textColor: textColor, backgroundColor: backgroundColor)
        return view
    }

    func updateNSView(_ view: TickerMotionCanvasNSView, context: Context) {
        view.configure(text: text, speed: speed, font: font, textColor: textColor, backgroundColor: backgroundColor)
    }
}

final class TickerMotionCanvasNSView: NSView {
    private let strip = CALayer()
    private var signature = ""
    private var pending: (String, Double, NSFont, CGColor, CGColor)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.cornerRadius = 6
        layer?.addSublayer(strip)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layout() {
        super.layout()
        guard let pending, bounds.width > 1 else { return }
        configure(text: pending.0, speed: pending.1, font: pending.2, textColor: pending.3, backgroundColor: pending.4)
    }

    func configure(text: String, speed: Double, font: NSFont, textColor: CGColor, backgroundColor: CGColor) {
        pending = (text, speed, font, textColor, backgroundColor)
        let next = "\(text)|\(speed)|\(font.pointSize)|\(bounds.width)"
        guard next != signature, bounds.width > 1, bounds.height > 1 else { return }
        signature = next
        layer?.backgroundColor = backgroundColor
        let rendered = TickerMotionGraphics.strip(text: text, font: font, color: textColor, height: bounds.height)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        strip.contents = rendered.image
        strip.contentsScale = NSScreen.main?.backingScaleFactor ?? 2
        strip.frame = CGRect(x: 0, y: 0, width: rendered.width, height: bounds.height)
        CATransaction.commit()
        TickerMotionGraphics.scroll(strip, distance: rendered.loopWidth, speed: speed)
    }
}
#else
import UIKit

struct TickerCoreMotionView: UIViewRepresentable {
    var text: String
    var speed: Double
    var font: UIFont
    var textColor: CGColor
    var backgroundColor: CGColor

    func makeUIView(context: Context) -> TickerMotionCanvasUIView {
        let view = TickerMotionCanvasUIView()
        view.configure(text: text, speed: speed, font: font, textColor: textColor, backgroundColor: backgroundColor)
        return view
    }

    func updateUIView(_ view: TickerMotionCanvasUIView, context: Context) {
        view.configure(text: text, speed: speed, font: font, textColor: textColor, backgroundColor: backgroundColor)
    }
}

final class TickerMotionCanvasUIView: UIView {
    private let strip = CALayer()
    private var signature = ""
    private var pending: (String, Double, UIFont, CGColor, CGColor)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        layer.cornerRadius = 6
        layer.addSublayer(strip)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let pending, bounds.width > 1 else { return }
        configure(text: pending.0, speed: pending.1, font: pending.2, textColor: pending.3, backgroundColor: pending.4)
    }

    func configure(text: String, speed: Double, font: UIFont, textColor: CGColor, backgroundColor: CGColor) {
        pending = (text, speed, font, textColor, backgroundColor)
        let next = "\(text)|\(speed)|\(font.pointSize)|\(bounds.width)"
        guard next != signature, bounds.width > 1, bounds.height > 1 else { return }
        signature = next
        layer.backgroundColor = backgroundColor
        let rendered = TickerMotionGraphics.strip(text: text, font: font, color: textColor, height: bounds.height)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        strip.contents = rendered.image
        strip.contentsScale = UITraitCollection.current.displayScale
        strip.frame = CGRect(x: 0, y: 0, width: rendered.width, height: bounds.height)
        CATransaction.commit()
        TickerMotionGraphics.scroll(strip, distance: rendered.loopWidth, speed: speed)
    }
}
#endif

enum TickerMotionGraphics {
    struct Strip {
        let image: CGImage
        let width: CGFloat
        let loopWidth: CGFloat
    }

    static func scroll(_ layer: CALayer, distance: CGFloat, speed: Double) {
        layer.removeAnimation(forKey: "scroll")
        let pointsPerSecond = max(20, speed)
        let travel = max(distance, 1)
        let move = CABasicAnimation(keyPath: "transform.translation.x")
        move.fromValue = 0
        move.toValue = -travel
        move.duration = CFTimeInterval(travel / pointsPerSecond)
        move.repeatCount = .infinity
        move.isRemovedOnCompletion = false
        layer.add(move, forKey: "scroll")
    }

#if os(macOS)
    static func strip(text: String, font: NSFont, color: CGColor, height: CGFloat) -> Strip {
        let spacing: CGFloat = 64
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(cgColor: color) ?? .white
        ]
        let textWidth = (text as NSString).size(withAttributes: attributes).width
        let loop = textWidth + spacing
        let width = max(loop * 2, 1)
        let image = NSImage(size: NSSize(width: width, height: height), flipped: false) { rect in
            let y = (rect.height - font.ascender - font.descender) / 2 - font.descender
            (text as NSString).draw(at: NSPoint(x: 16, y: y), withAttributes: attributes)
            (text as NSString).draw(at: NSPoint(x: 16 + loop, y: y), withAttributes: attributes)
            return true
        }
        var proposed = CGRect(origin: .zero, size: image.size)
        let cg = image.cgImage(forProposedRect: &proposed, context: nil, hints: nil)
        return Strip(image: cg ?? TickerMotionGraphics.emptyImage(width: width, height: height), width: width, loopWidth: loop)
    }
#else
    static func strip(text: String, font: UIFont, color: CGColor, height: CGFloat) -> Strip {
        let spacing: CGFloat = 64
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(cgColor: color)
        ]
        let textWidth = (text as NSString).size(withAttributes: attributes).width
        let loop = textWidth + spacing
        let width = max(loop * 2, 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = UITraitCollection.current.displayScale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        let image = renderer.image { _ in
            let y = (height - font.lineHeight) / 2
            (text as NSString).draw(at: CGPoint(x: 16, y: y), withAttributes: attributes)
            (text as NSString).draw(at: CGPoint(x: 16 + loop, y: y), withAttributes: attributes)
        }
        return Strip(image: image.cgImage ?? emptyImage(width: width, height: height), width: width, loopWidth: loop)
    }
#endif

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
