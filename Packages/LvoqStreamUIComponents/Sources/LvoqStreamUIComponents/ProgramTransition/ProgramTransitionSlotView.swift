import Foundation

/// Platform slot surface for transition transforms (implemented per OS in `+UIKit` / `+AppKit`).
@MainActor
protocol ProgramTransitionSlotView: AnyObject {
    func setTransitionOpacity(_ opacity: Double)
    func applyTransitionSlot(_ slot: ProgramTransitionSlot, containerWidth: CGFloat)
    func resetTransitionPresentation()
}

@MainActor
enum ProgramTransitionSlotPresenter {
    static func apply(_ slot: ProgramTransitionSlot, to view: ProgramTransitionSlotView, containerWidth: CGFloat) {
        view.applyTransitionSlot(slot, containerWidth: containerWidth)
    }

    static func reset(_ view: ProgramTransitionSlotView) {
        view.resetTransitionPresentation()
    }

    static func setOpacity(_ opacity: Double, on view: ProgramTransitionSlotView) {
        view.setTransitionOpacity(opacity)
    }
}
