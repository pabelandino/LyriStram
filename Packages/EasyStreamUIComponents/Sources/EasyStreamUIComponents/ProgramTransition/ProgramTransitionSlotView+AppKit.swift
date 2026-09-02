#if canImport(AppKit)
import AppKit

extension NSView: ProgramTransitionSlotView {
    func setTransitionOpacity(_ opacity: Double) {
        alphaValue = opacity
    }

    func applyTransitionSlot(_ slot: ProgramTransitionSlot, containerWidth: CGFloat) {
        guard layer != nil else { return }
        let offsetX = CGFloat(slot.offsetX) * containerWidth
        let scale = CGFloat(slot.scale)
        layer?.setAffineTransform(
            CGAffineTransform(translationX: offsetX, y: 0).scaledBy(x: scale, y: scale)
        )
        applyRevealMask(reveal: slot.reveal)
    }

    func resetTransitionPresentation() {
        layer?.setAffineTransform(.identity)
        ProgramTransitionRevealMask.clear(from: layer)
    }

    private func applyRevealMask(reveal: Double?) {
        guard let layer else { return }
        ProgramTransitionRevealMask.apply(reveal: reveal, to: layer, bounds: bounds)
    }
}
#endif
