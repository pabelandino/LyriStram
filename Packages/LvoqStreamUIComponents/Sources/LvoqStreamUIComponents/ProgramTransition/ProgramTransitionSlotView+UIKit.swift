#if canImport(UIKit)
import UIKit

extension UIView: ProgramTransitionSlotView {
    func setTransitionOpacity(_ opacity: Double) {
        alpha = CGFloat(opacity)
    }

    func applyTransitionSlot(_ slot: ProgramTransitionSlot, containerWidth: CGFloat) {
        let offsetX = CGFloat(slot.offsetX) * containerWidth
        let scale = CGFloat(slot.scale)
        transform = CGAffineTransform(translationX: offsetX, y: 0).scaledBy(x: scale, y: scale)
        applyRevealMask(reveal: slot.reveal)
    }

    func resetTransitionPresentation() {
        transform = .identity
        ProgramTransitionRevealMask.clear(from: layer)
    }

    private func applyRevealMask(reveal: Double?) {
        ProgramTransitionRevealMask.apply(reveal: reveal, to: layer, bounds: bounds)
    }
}
#endif
