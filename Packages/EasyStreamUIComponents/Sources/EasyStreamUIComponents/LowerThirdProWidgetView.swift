import SwiftUI
import EasyStreamCore

struct LowerThirdProWidgetView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let isLive: Bool
    var onLiveSequenceEnded: (() -> Void)?

    @State private var phase: SequencePhase = .offscreen

    enum SequencePhase: Equatable {
        case offscreen, onscreen
    }

    var body: some View {
        content
            .offset(y: phase == .onscreen ? 0 : 90)
            .opacity(phase == .onscreen ? 1 : 0)
            .onAppear { restartSequenceIfNeeded() }
            .onChange(of: isLive) { _, live in
                if live { restartSequenceIfNeeded() } else { phase = .onscreen }
            }
            .onChange(of: phase) { _, newPhase in
                guard newPhase == .offscreen, isLive, configuration.autoPlaySequence else { return }
                onLiveSequenceEnded?()
            }
    }

    private var content: some View {
        HStack(spacing: 14) {
            CachedWidgetLogoView(logoURL: logoURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } placeholder: {
                Color.clear.frame(width: 52, height: 52)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(configuration.title)
                    .font(BroadcastWidgetTypography.font(
                        configuration.titleFont,
                        size: configuration.titleFontSize,
                        weight: .bold
                    ))
                    .foregroundStyle(BroadcastWidgetColors.color(hex: configuration.resolvedTitleColorHex))
                if let subtitle = configuration.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(BroadcastWidgetTypography.font(
                            configuration.subtitleFont,
                            size: configuration.subtitleFontSize
                        ))
                        .foregroundStyle(BroadcastWidgetColors.color(hex: configuration.resolvedSubtitleColorHex))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background {
            Group {
                if configuration.resolvedUseLowerThirdGradient {
                    BroadcastWidgetColors.gradient(
                        configuration.resolvedLowerThirdGradient(fallbackAccent: configuration.accentColorHex)
                    )
                } else {
                    BroadcastWidgetColors.color(hex: configuration.accentColorHex).opacity(0.92)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
    }

    private func restartSequenceIfNeeded() {
        guard configuration.autoPlaySequence, isLive else {
            phase = .onscreen
            return
        }

        phase = .offscreen
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(60))
            withAnimation(.spring(response: configuration.animateInSeconds, dampingFraction: 0.82)) {
                phase = .onscreen
            }
            try? await Task.sleep(for: .seconds(configuration.holdDurationSeconds))
            withAnimation(.easeInOut(duration: configuration.animateOutSeconds)) {
                phase = .offscreen
            }
        }
    }
}
