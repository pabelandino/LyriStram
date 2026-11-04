import CoreGraphics
import Foundation

public struct LowerThirdFrame: Equatable, Hashable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var rect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}

public enum LowerThirdPieceKind: Equatable, Hashable, Sendable {
    case logo
    case lightBar
    case darkBar
    case accentBar
    case titleBlock
    case nameBlock
}

public struct LowerThirdPiece: Equatable, Hashable, Sendable, Identifiable {
    public var kind: LowerThirdPieceKind
    public var frame: LowerThirdFrame
    public var barIndex: Int

    public var id: String {
        "\(kind)-\(barIndex)"
    }

    public init(kind: LowerThirdPieceKind, frame: LowerThirdFrame, barIndex: Int) {
        self.kind = kind
        self.frame = frame
        self.barIndex = barIndex
    }
}

public enum LowerThirdLayout {
    public static let width: Double = 1180
    public static let height: Double = 280

    public static func pieces(style: BroadcastLowerThirdStyle, hasThirdLine: Bool) -> [LowerThirdPiece] {
        switch style {
        case .angular:
            var pieces = [
                LowerThirdPiece(kind: .logo, frame: LowerThirdFrame(x: 16, y: 42, width: 196, height: 188), barIndex: -1),
                LowerThirdPiece(kind: .lightBar, frame: LowerThirdFrame(x: 148, y: 34, width: 880, height: 60), barIndex: 0),
                LowerThirdPiece(kind: .darkBar, frame: LowerThirdFrame(x: 128, y: 82, width: 960, height: 60), barIndex: 1)
            ]
            if hasThirdLine {
                pieces.append(
                    LowerThirdPiece(kind: .accentBar, frame: LowerThirdFrame(x: 220, y: 130, width: 680, height: 56), barIndex: 2)
                )
            }
            return pieces
        case .titlePlate:
            return [
                LowerThirdPiece(kind: .logo, frame: LowerThirdFrame(x: 32, y: 20, width: 240, height: 128), barIndex: -1),
                LowerThirdPiece(kind: .titleBlock, frame: LowerThirdFrame(x: 32, y: 112, width: 1080, height: 150), barIndex: 0)
            ]
        case .guest:
            return [
                LowerThirdPiece(kind: .logo, frame: LowerThirdFrame(x: 12, y: 14, width: 252, height: 252), barIndex: -1),
                LowerThirdPiece(kind: .nameBlock, frame: LowerThirdFrame(x: 300, y: 58, width: 836, height: 188), barIndex: 0)
            ]
        case .guestPlain:
            return [
                LowerThirdPiece(kind: .nameBlock, frame: LowerThirdFrame(x: 24, y: 58, width: 1120, height: 188), barIndex: 0)
            ]
        }
    }

    /// Fits the design inside a placement slot without stretching. Fractions are of a 16:9 program frame.
    public static func fittedFractions(slotWidth: Double, slotHeight: Double, programAspect: Double = 16.0 / 9.0) -> (width: Double, height: Double) {
        let designAspect = width / height
        let safeHeight = max(slotHeight, 0.001)
        let slotAspect = (slotWidth / safeHeight) * programAspect
        if slotAspect > designAspect {
            return (safeHeight * designAspect / programAspect, safeHeight)
        }
        return (slotWidth, slotWidth * programAspect / designAspect)
    }

    public static func fittedSize(in size: CGSize) -> CGSize {
        let aspect = width / height
        let safeHeight = max(size.height, 1)
        let sizeAspect = size.width / safeHeight
        if sizeAspect > aspect {
            return CGSize(width: safeHeight * aspect, height: safeHeight)
        }
        return CGSize(width: size.width, height: size.width / aspect)
    }
}
