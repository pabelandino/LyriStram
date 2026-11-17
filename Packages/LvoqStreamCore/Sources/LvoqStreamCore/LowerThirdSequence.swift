import Foundation

public struct LowerThirdCue: Equatable, Sendable {
    public var enterDelay: Double
    public var enterDuration: Double
    public var exitDelay: Double
    public var exitDuration: Double
    public var slideFraction: Double
    public var enterScale: Double

    public init(
        enterDelay: Double,
        enterDuration: Double,
        exitDelay: Double,
        exitDuration: Double,
        slideFraction: Double,
        enterScale: Double
    ) {
        self.enterDelay = enterDelay
        self.enterDuration = enterDuration
        self.exitDelay = exitDelay
        self.exitDuration = exitDuration
        self.slideFraction = slideFraction
        self.enterScale = enterScale
    }

    public func sample(elapsed: Double) -> (offsetFraction: Double, opacity: Double, scale: Double) {
        let enterSpan = max(enterDuration, 0.01)
        let exitSpan = max(exitDuration, 0.01)
        if elapsed < enterDelay {
            return (slideFraction, 0, enterScale)
        }
        if elapsed < enterDelay + enterSpan {
            let progress = smooth((elapsed - enterDelay) / enterSpan)
            return (
                slideFraction * (1 - progress),
                progress,
                enterScale + (1 - enterScale) * progress
            )
        }
        if elapsed < exitDelay {
            return (0, 1, 1)
        }
        if elapsed < exitDelay + exitSpan {
            let progress = smooth((elapsed - exitDelay) / exitSpan)
            return (
                slideFraction * progress,
                1 - progress,
                1 + (enterScale - 1) * progress
            )
        }
        return (slideFraction, 0, enterScale)
    }

    private func smooth(_ value: Double) -> Double {
        let t = min(max(value, 0), 1)
        return t * t * (3 - 2 * t)
    }
}

public struct LowerThirdSequence: Equatable, Sendable {
    public var logo: LowerThirdCue
    public var bars: [LowerThirdCue]
    public var totalDuration: Double

    public static func make(
        style: BroadcastLowerThirdStyle,
        hasThirdLine: Bool,
        animateIn: Double,
        hold: Double,
        animateOut: Double
    ) -> LowerThirdSequence {
        let enter = min(max(animateIn, 0.28), 2.5)
        let exit = min(max(animateOut, 0.24), 2)
        let visibleHold = min(max(hold, 0), 30)
        let barCount = style == .angular ? (hasThirdLine ? 3 : 2) : 1
        let stagger = enter * 0.2

        var logo = LowerThirdCue(
            enterDelay: 0,
            enterDuration: enter * 0.7,
            exitDelay: 0,
            exitDuration: exit * 0.65,
            slideFraction: -0.32,
            enterScale: 0.84
        )
        var bars: [LowerThirdCue] = []
        for index in 0..<barCount {
            bars.append(
                LowerThirdCue(
                    enterDelay: enter * 0.32 + Double(index) * stagger,
                    enterDuration: enter * 0.85,
                    exitDelay: 0,
                    exitDuration: exit * 0.72,
                    slideFraction: -1.08,
                    enterScale: 1
                )
            )
        }

        let settled = bars.map { $0.enterDelay + $0.enterDuration }.max() ?? enter
        let exitStart = settled + visibleHold
        for index in bars.indices {
            bars[index].exitDelay = exitStart + Double(index) * (exit * 0.16)
        }
        let barsDone = bars.map { $0.exitDelay + $0.exitDuration }.max() ?? (exitStart + exit)
        logo.exitDelay = max(logo.enterDelay + logo.enterDuration, barsDone - exit * 0.2)
        let total = max(logo.exitDelay + logo.exitDuration, barsDone) + 0.05
        return LowerThirdSequence(logo: logo, bars: bars, totalDuration: total)
    }
}

public enum LowerThirdContrast {
    public static func textHex(_ preferred: String, on backgroundHex: String) -> String {
        let text = luminance(preferred)
        let background = luminance(backgroundHex)
        if abs(text - background) >= 0.38 {
            return normalized(preferred)
        }
        return background > 0.55 ? "1A1A1A" : "FFFFFF"
    }

    private static func normalized(_ hex: String) -> String {
        var raw = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.hasPrefix("#") { raw.removeFirst() }
        // Color wells store AARRGGBB. The first byte is alpha, not red.
        if raw.count >= 8 {
            raw = String(raw.dropFirst(2).prefix(6))
        } else if raw.count >= 6 {
            raw = String(raw.prefix(6))
        } else {
            raw = "FFFFFF"
        }
        return raw.uppercased()
    }

    private static func luminance(_ hex: String) -> Double {
        let rgb = normalized(hex)
        let value = UInt64(rgb, radix: 16) ?? 0xFFFFFF
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        return red * 0.2126 + green * 0.7152 + blue * 0.0722
    }
}
