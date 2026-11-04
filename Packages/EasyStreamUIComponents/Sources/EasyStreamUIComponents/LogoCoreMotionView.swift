import SwiftUI
import EasyStreamCore
import QuartzCore

#if os(macOS)
import AppKit

struct LogoCoreMotionView: NSViewRepresentable {
    var imageURL: URL?
    var kind: BroadcastLogoAnimation
    var speed: Double
    var epoch: Date
    var accentHex: String

    func makeNSView(context: Context) -> LogoMotionCanvasNSView {
        let view = LogoMotionCanvasNSView()
        view.configure(imageURL: imageURL, kind: kind, speed: speed, epoch: epoch, accentHex: accentHex)
        return view
    }

    func updateNSView(_ view: LogoMotionCanvasNSView, context: Context) {
        view.configure(imageURL: imageURL, kind: kind, speed: speed, epoch: epoch, accentHex: accentHex)
    }
}

final class LogoMotionCanvasNSView: NSView {
    private let imageLayer = CALayer()
    private var appliedURL: URL?
    private var appliedKind: BroadcastLogoAnimation = .none
    private var appliedSpeed = 0.0
    private var appliedEpoch = Date.distantPast
    private var loadGeneration = 0

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layerContentsRedrawPolicy = .never
        imageLayer.contentsGravity = .resizeAspect
        imageLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2
        imageLayer.masksToBounds = false
        imageLayer.backgroundColor = nil
        layer?.addSublayer(imageLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layout() {
        super.layout()
        guard imageLayer.frame != bounds else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        imageLayer.frame = bounds
        CATransaction.commit()
    }

    func configure(imageURL: URL?, kind: BroadcastLogoAnimation, speed: Double, epoch: Date, accentHex: String) {
        let unchanged = imageURL == appliedURL
            && kind == appliedKind
            && speed == appliedSpeed
            && epoch == appliedEpoch
        guard !unchanged else { return }
        appliedURL = imageURL
        appliedKind = kind
        appliedSpeed = speed
        appliedEpoch = epoch
        loadImage(at: imageURL)
        LogoMotionGraphics.apply(to: imageLayer, kind: kind, speed: speed)
    }

    private func loadImage(at url: URL?) {
        loadGeneration += 1
        let generation = loadGeneration
        guard let url else {
            imageLayer.contents = nil
            return
        }
        Task { @MainActor in
            let data = await Task.detached(priority: .utility) {
                try? Data(contentsOf: url)
            }.value
            guard generation == self.loadGeneration else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.imageLayer.contents = data.flatMap { NSImage(data: $0) }
            CATransaction.commit()
        }
    }
}
#else
import UIKit

struct LogoCoreMotionView: UIViewRepresentable {
    var imageURL: URL?
    var kind: BroadcastLogoAnimation
    var speed: Double
    var epoch: Date
    var accentHex: String

    func makeUIView(context: Context) -> LogoMotionCanvasUIView {
        let view = LogoMotionCanvasUIView()
        view.configure(imageURL: imageURL, kind: kind, speed: speed, epoch: epoch, accentHex: accentHex)
        return view
    }

    func updateUIView(_ view: LogoMotionCanvasUIView, context: Context) {
        view.configure(imageURL: imageURL, kind: kind, speed: speed, epoch: epoch, accentHex: accentHex)
    }
}

final class LogoMotionCanvasUIView: UIView {
    private let imageLayer = CALayer()
    private var appliedURL: URL?
    private var appliedKind: BroadcastLogoAnimation = .none
    private var appliedSpeed = 0.0
    private var appliedEpoch = Date.distantPast
    private var loadGeneration = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageLayer.contentsGravity = .resizeAspect
        imageLayer.contentsScale = UITraitCollection.current.displayScale
        imageLayer.masksToBounds = false
        imageLayer.backgroundColor = nil
        layer.addSublayer(imageLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard imageLayer.frame != bounds else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        imageLayer.frame = bounds
        CATransaction.commit()
    }

    func configure(imageURL: URL?, kind: BroadcastLogoAnimation, speed: Double, epoch: Date, accentHex: String) {
        let unchanged = imageURL == appliedURL
            && kind == appliedKind
            && speed == appliedSpeed
            && epoch == appliedEpoch
        guard !unchanged else { return }
        appliedURL = imageURL
        appliedKind = kind
        appliedSpeed = speed
        appliedEpoch = epoch
        _ = accentHex
        loadImage(at: imageURL)
        LogoMotionGraphics.apply(to: imageLayer, kind: kind, speed: speed)
    }

    private func loadImage(at url: URL?) {
        loadGeneration += 1
        let generation = loadGeneration
        guard let url else {
            imageLayer.contents = nil
            return
        }
        Task { @MainActor in
            let data = await Task.detached(priority: .utility) {
                try? Data(contentsOf: url)
            }.value
            guard generation == self.loadGeneration else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.imageLayer.contents = data.flatMap { UIImage(data: $0)?.cgImage }
            CATransaction.commit()
        }
    }
}
#endif

enum LogoMotionGraphics {
    static func apply(to layer: CALayer, kind: BroadcastLogoAnimation, speed: Double) {
        layer.removeAllAnimations()
        var base = CATransform3DIdentity
        base.m34 = -1.0 / 700.0
        layer.transform = base
        guard kind != .none else { return }

        let spin = 1.0 / (0.45 * min(max(speed, 0.25), 3))
        let pause = spin
        let turn = CAKeyframeAnimation(keyPath: "transform.rotation.y")
        turn.values = [0, Double.pi * 2, Double.pi * 2]
        turn.keyTimes = [0, NSNumber(value: spin / (spin + pause)), 1]
        turn.duration = spin + pause
        turn.calculationMode = .linear
        turn.repeatCount = .infinity
        turn.isRemovedOnCompletion = false
        layer.add(turn, forKey: "spin")
    }

    static func cgColor(hex: String) -> CGColor {
        var raw = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.hasPrefix("#") { raw.removeFirst() }
        guard raw.count >= 6, let value = UInt64(String(raw.prefix(6)), radix: 16) else {
            return CGColor(gray: 0.45, alpha: 1)
        }
        return CGColor(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
