import SwiftUI
import EasyStreamCore

public struct BroadcastWidgetContentView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let isLive: Bool
    let allowsMotion: Bool
    var onLiveSequenceEnded: (() -> Void)?

    public init(
        configuration: BroadcastWidgetConfiguration,
        logoURL: URL?,
        isLive: Bool,
        allowsMotion: Bool = true,
        onLiveSequenceEnded: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.logoURL = logoURL
        self.isLive = isLive
        self.allowsMotion = allowsMotion
        self.onLiveSequenceEnded = onLiveSequenceEnded
    }

    public var body: some View {
        switch configuration.resolvedTemplate {
        case .animatedLogo, .logo:
            AnimatedLogoWidgetView(
                configuration: configuration,
                logoURL: logoURL,
                allowsMotion: allowsMotion
            )
        case .ticker, .textBanner:
            TickerWidgetView(configuration: configuration)
        case .lowerThirdPro, .lowerThird:
            LowerThirdProWidgetView(
                configuration: configuration,
                logoURL: logoURL,
                isLive: isLive,
                onLiveSequenceEnded: onLiveSequenceEnded
            )
        case .clock:
            ClockWidgetView(configuration: configuration)
        case .countdown:
            CountdownWidgetView(configuration: configuration, isLive: isLive)
        }
    }
}
