import SwiftUI
import EasyStreamCore

struct ClockWidgetView: View {
    let configuration: BroadcastWidgetConfiguration

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(alignment: .trailing, spacing: 2) {
                Text(timeString(for: context.date))
                    .font(BroadcastWidgetTypography.font(
                        configuration.titleFont,
                        size: configuration.titleFontSize,
                        weight: .bold
                    ))
                    .monospacedDigit()
                if configuration.clockShowsDate {
                    Text(dateString(for: context.date))
                        .font(BroadcastWidgetTypography.font(
                            configuration.subtitleFont,
                            size: configuration.subtitleFontSize
                        ))
                        .opacity(0.85)
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func timeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        if configuration.clockUse24Hour {
            formatter.dateFormat = configuration.clockShowsSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            formatter.dateFormat = configuration.clockShowsSeconds ? "h:mm:ss a" : "h:mm a"
        }
        return formatter.string(from: date)
    }

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
