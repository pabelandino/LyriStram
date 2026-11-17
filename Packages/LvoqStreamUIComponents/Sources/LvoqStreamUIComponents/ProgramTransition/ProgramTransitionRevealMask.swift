#if canImport(QuartzCore)
import QuartzCore

enum ProgramTransitionRevealMask {
    static func apply(reveal: Double?, to layer: CALayer, bounds: CGRect) {
        guard let reveal, reveal < 0.999 else {
            layer.mask = nil
            return
        }

        let maskLayer: CAShapeLayer
        if let existing = layer.mask as? CAShapeLayer {
            maskLayer = existing
        } else {
            let created = CAShapeLayer()
            layer.mask = created
            maskLayer = created
        }

        let width = bounds.width * reveal
        maskLayer.path = CGPath(
            rect: CGRect(x: 0, y: 0, width: max(width, 0), height: bounds.height),
            transform: nil
        )
    }

    static func clear(from layer: CALayer?) {
        layer?.mask = nil
    }
}
#endif
