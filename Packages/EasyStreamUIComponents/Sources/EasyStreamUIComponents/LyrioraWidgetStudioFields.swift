import SwiftUI
import EasyStreamCore

struct LyrioraWidgetStudioFields: View {
    @Binding var configuration: BroadcastWidgetConfiguration

    private var feed: LyrioraAirFeed { .shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LyrioraAirStatusBadge(title: feed.statusTitle, isOnAir: feed.isOnAir)

            VStack(alignment: .leading, spacing: 8) {
                Text("Presentación")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BroadcastTheme.subtleText)
                HStack(spacing: 8) {
                    ForEach(LyrioraPresentationMode.allCases, id: \.self) { mode in
                        Button(mode.title) {
                            select(mode)
                        }
                        .buttonStyle(.plain)
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(configuration.resolvedLyrioraMode == mode
                                      ? BroadcastTheme.studioAccent.opacity(0.28)
                                      : BroadcastTheme.panelElevated)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Estilo")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BroadcastTheme.subtleText)
                HStack(spacing: 8) {
                    ForEach(LyrioraVisualStyle.allCases, id: \.self) { style in
                        Button(style.title) {
                            configuration.lyrioraStyle = style
                        }
                        .buttonStyle(.plain)
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(configuration.resolvedLyrioraStyle == style
                                      ? BroadcastTheme.studioAccent.opacity(0.28)
                                      : BroadcastTheme.panelElevated)
                        }
                    }
                }
            }

            Text("Las letras entran como lower. Un versículo puede ir en lower o a pantalla completa. Con el widget al aire, el texto sigue a Lyriora.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func select(_ mode: LyrioraPresentationMode) {
        configuration.lyrioraMode = mode
        configuration.placement = mode == .fullScreen ? .lyrioraFullScreen : .lyrioraLower
    }
}
