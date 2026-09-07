import SwiftUI
import EasyStreamCore

#if os(macOS)
import AppKit
#endif
// MARK: - Placement geometry (crop-overlay style: anchor opposite corner)

enum WidgetPlacementGeometry {
    static func rect(
        from placement: BroadcastWidgetPlacement,
        canvas: CGSize,
        sizing: WidgetOverlayContentSizing
    ) -> CGRect {
        guard canvas.width > 0, canvas.height > 0 else { return .zero }

        var width = max(1, canvas.width * placement.widthFraction)
        var height = max(1, canvas.height * placement.heightFraction)
        if sizing == .uniformSquare {
            let side = min(width, height)
            width = side
            height = side
        }

        let centerX = canvas.width * placement.normalizedCenterX
        let centerY = canvas.height * placement.normalizedCenterY
        return CGRect(
            x: centerX - width / 2,
            y: centerY - height / 2,
            width: width,
            height: height
        )
    }

    static func placement(from rect: CGRect, canvas: CGSize) -> BroadcastWidgetPlacement {
        BroadcastWidgetPlacement(
            normalizedCenterX: Double(rect.midX / canvas.width),
            normalizedCenterY: Double(rect.midY / canvas.height),
            widthFraction: Double(rect.width / canvas.width),
            heightFraction: Double(rect.height / canvas.height)
        )
    }

    static func resized(
        from start: BroadcastWidgetPlacement,
        corner: WidgetResizeCorner,
        translation: CGSize,
        canvas: CGSize,
        sizing: WidgetOverlayContentSizing,
        minSize: CGFloat
    ) -> BroadcastWidgetPlacement {
        let startRect = rect(from: start, canvas: canvas, sizing: sizing)
        let anchor = corner.opposite.point(in: startRect)
        var dragged = corner.point(in: startRect)
        dragged.x += translation.width
        dragged.y += translation.height

        var nextRect = rectFromAnchor(anchor: anchor, dragged: dragged, minSize: minSize)

        if sizing == .uniformSquare {
            let side = max(minSize, max(nextRect.width, nextRect.height))
            nextRect = squareRect(fixedCorner: corner.opposite, at: anchor, side: side)
        }

        nextRect = clamp(nextRect, in: canvas, minSize: minSize)
        return placement(from: nextRect, canvas: canvas)
    }

    private static func rectFromAnchor(anchor: CGPoint, dragged: CGPoint, minSize: CGFloat) -> CGRect {
        let minX = min(anchor.x, dragged.x)
        let minY = min(anchor.y, dragged.y)
        let maxX = max(anchor.x, dragged.x)
        let maxY = max(anchor.y, dragged.y)
        return CGRect(
            x: minX,
            y: minY,
            width: max(minSize, maxX - minX),
            height: max(minSize, maxY - minY)
        )
    }

    private static func squareRect(fixedCorner: WidgetResizeCorner, at anchor: CGPoint, side: CGFloat) -> CGRect {
        switch fixedCorner {
        case .topLeading:
            return CGRect(x: anchor.x, y: anchor.y, width: side, height: side)
        case .topTrailing:
            return CGRect(x: anchor.x - side, y: anchor.y, width: side, height: side)
        case .bottomLeading:
            return CGRect(x: anchor.x, y: anchor.y - side, width: side, height: side)
        case .bottomTrailing:
            return CGRect(x: anchor.x - side, y: anchor.y - side, width: side, height: side)
        }
    }

    private static func clamp(_ rect: CGRect, in canvas: CGSize, minSize: CGFloat) -> CGRect {
        var r = rect
        r.size.width = min(canvas.width, max(minSize, r.width))
        r.size.height = min(canvas.height, max(minSize, r.height))

        if r.minX < 0 { r.origin.x = 0 }
        if r.minY < 0 { r.origin.y = 0 }
        if r.maxX > canvas.width { r.origin.x = canvas.width - r.width }
        if r.maxY > canvas.height { r.origin.y = canvas.height - r.height }

        r.origin.x = max(0, min(r.origin.x, canvas.width - r.width))
        r.origin.y = max(0, min(r.origin.y, canvas.height - r.height))
        return r
    }
}

enum WidgetResizeCorner: CaseIterable {
    case topLeading, topTrailing, bottomLeading, bottomTrailing

    var opposite: WidgetResizeCorner {
        switch self {
        case .topLeading: .bottomTrailing
        case .topTrailing: .bottomLeading
        case .bottomLeading: .topTrailing
        case .bottomTrailing: .topLeading
        }
    }

    func point(in rect: CGRect) -> CGPoint {
        switch self {
        case .topLeading: CGPoint(x: rect.minX, y: rect.minY)
        case .topTrailing: CGPoint(x: rect.maxX, y: rect.minY)
        case .bottomLeading: CGPoint(x: rect.minX, y: rect.maxY)
        case .bottomTrailing: CGPoint(x: rect.maxX, y: rect.maxY)
        }
    }

#if os(macOS)
    func pushCursor() {
        NSCursor.crosshair.push()
    }
#endif
}

enum WidgetPlacementChrome {
    static let handleHitSize: CGFloat = 48
}
