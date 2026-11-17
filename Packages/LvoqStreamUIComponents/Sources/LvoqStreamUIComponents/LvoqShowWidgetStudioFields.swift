import SwiftUI
import LvoqStreamCore

struct LvoqShowWidgetStudioFields: View {
    @Binding var configuration: BroadcastWidgetConfiguration

    private var feed: LvoqShowAirFeed { .shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LvoqShowAirStatusBadge(title: feed.statusTitle, isOnAir: feed.isOnAir)

            VStack(alignment: .leading, spacing: 8) {
                Text(BundleLocalization.string("Presentación"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BroadcastTheme.subtleText)
                HStack(spacing: 8) {
                    ForEach(LvoqShowPresentationMode.allCases, id: \.self) { mode in
                        Button(mode.title) {
                            select(mode)
                        }
                        .buttonStyle(.plain)
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(configuration.resolvedLvoqShowMode == mode
                                      ? BroadcastTheme.studioAccent.opacity(0.28)
                                      : BroadcastTheme.panelElevated)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(BundleLocalization.string("common.style"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BroadcastTheme.subtleText)
                HStack(spacing: 8) {
                    ForEach(LvoqShowVisualStyle.allCases, id: \.self) { style in
                        Button(style.title) {
                            configuration.lvoqshowStyle = style
                        }
                        .buttonStyle(.plain)
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(configuration.resolvedLvoqShowStyle == style
                                      ? BroadcastTheme.studioAccent.opacity(0.28)
                                      : BroadcastTheme.panelElevated)
                        }
                    }
                }
            }

            Text(BundleLocalization.string("Las letras entran como lower. Un versículo puede ir en lower o a pantalla completa. Con el widget al aire, el texto sigue a LvoqShow."))
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func select(_ mode: LvoqShowPresentationMode) {
        configuration.lvoqshowMode = mode
        configuration.placement = mode == .fullScreen ? .lvoqshowFullScreen : .lvoqshowLower
    }
}
