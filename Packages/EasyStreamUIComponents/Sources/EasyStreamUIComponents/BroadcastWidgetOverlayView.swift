import SwiftUI
import EasyStreamCore

public struct BroadcastWidgetOverlayView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let isLive: Bool

    public init(
        configuration: BroadcastWidgetConfiguration,
        logoURL: URL? = nil,
        isLive: Bool = true
    ) {
        self.configuration = configuration
        self.logoURL = logoURL
        self.isLive = isLive
    }

    public var body: some View {
        GeometryReader { geometry in
            BroadcastWidgetContentView(
                configuration: configuration,
                logoURL: logoURL,
                isLive: isLive
            )
            .frame(
                width: geometry.size.width * configuration.placement.widthFraction,
                height: geometry.size.height * configuration.placement.heightFraction
            )
            .position(
                x: geometry.size.width * configuration.placement.normalizedCenterX,
                y: geometry.size.height * configuration.placement.normalizedCenterY
            )
        }
    }
}
