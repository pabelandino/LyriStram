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
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
            TickerScrollingContent(
                text: displayText,
                configuration: configuration,
                elapsed: timeline.date.timeIntervalSinceReferenceDate
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

struct TickerScrollingContent: View {
    let text: String
    let configuration: BroadcastWidgetConfiguration
    let elapsed: TimeInterval

    private let labelSpacing: CGFloat = 64

    private var measuredSegmentWidth: CGFloat {
        BroadcastWidgetTypography.measureTextWidth(
            text,
            preset: configuration.titleFont,
            size: configuration.titleFontSize,
            weight: .semibold
        )
    }

    var body: some View {
        GeometryReader { geo in
            let speed = max(20, configuration.tickerSpeed)
            let period = max(measuredSegmentWidth + labelSpacing, 1)
            let copyCount = max(3, Int(ceil(geo.size.width / period)) + 2)
            let offset = -(elapsed * speed).truncatingRemainder(dividingBy: period)

            ZStack {
                Group {
                    if configuration.resolvedUseTickerGradient {
                        BroadcastWidgetColors.gradient(configuration.tickerGradient)
                    } else {
                        BroadcastWidgetColors.color(
                            hex: configuration.resolvedTickerBackgroundHex,
                            fallback: Color.black.opacity(0.8)
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                HStack(spacing: labelSpacing) {
                    ForEach(0..<copyCount, id: \.self) { _ in
                        tickerLabel
                    }
                }
                .offset(x: offset)
                .frame(maxHeight: .infinity, alignment: .center)
            }
        }
    }

    private var tickerLabel: some View {
        Text(verbatim: text)
            .font(BroadcastWidgetTypography.font(
                configuration.titleFont,
                size: configuration.titleFontSize,
                weight: .semibold
            ))
            .foregroundStyle(BroadcastWidgetColors.color(
                hex: configuration.resolvedTickerTextColorHex,
                fallback: .white
            ))
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 16)
    }
}
