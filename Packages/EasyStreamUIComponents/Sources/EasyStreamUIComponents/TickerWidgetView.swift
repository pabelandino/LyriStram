import SwiftUI
import EasyStreamCore

struct TickerWidgetView: View {
    let configuration: BroadcastWidgetConfiguration

    private var displayText: String {
        let raw = configuration.tickerText.isEmpty
            ? (configuration.tickerTexts.first ?? configuration.title)
            : configuration.tickerText
        let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !line.isEmpty else { return " " }
        return line.hasSuffix(" ") ? line : line + " "
    }

    var body: some View {
        TickerCoreMotionView(
            text: displayText,
            speed: configuration.tickerSpeed,
            font: BroadcastWidgetTypography.platformFont(
                preset: .condensed,
                size: 28,
                weight: .bold
            ),
            textColor: LogoMotionGraphics.cgColor(hex: configuration.resolvedTickerTextColorHex),
            backgroundColor: configuration.resolvedUseTickerGradient
                ? nil
                : LogoMotionGraphics.cgColor(hex: configuration.resolvedTickerBackgroundHex),
            gradientStart: configuration.resolvedUseTickerGradient
                ? LogoMotionGraphics.cgColor(hex: configuration.tickerGradient.startColorHex)
                : nil,
            gradientEnd: configuration.resolvedUseTickerGradient
                ? LogoMotionGraphics.cgColor(hex: configuration.tickerGradient.endColorHex)
                : nil,
            gradientAngle: configuration.tickerGradient.angleDegrees
        )
    }
}
