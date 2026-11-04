import SwiftUI
import EasyStreamCore

struct TickerWidgetView: View {
    let configuration: BroadcastWidgetConfiguration

    private var displayText: String {
        configuration.tickerText.isEmpty
            ? (configuration.tickerTexts.first ?? configuration.title)
            : configuration.tickerText
    }

    var body: some View {
        TickerCoreMotionView(
            text: displayText,
            speed: configuration.tickerSpeed,
            font: BroadcastWidgetTypography.platformFont(
                preset: configuration.titleFont,
                size: configuration.titleFontSize,
                weight: .semibold
            ),
            textColor: LogoMotionGraphics.cgColor(hex: configuration.resolvedTickerTextColorHex),
            backgroundColor: LogoMotionGraphics.cgColor(hex: configuration.resolvedTickerBackgroundHex)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
