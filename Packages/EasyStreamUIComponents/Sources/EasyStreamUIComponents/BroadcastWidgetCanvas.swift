import SwiftUI
import EasyStreamCore

public struct BroadcastWidgetCanvas: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let isEditing: Bool
    let isLive: Bool
    let allowsMotion: Bool
    @Binding var placement: BroadcastWidgetPlacement
    var onLiveSequenceEnded: (() -> Void)?

    public init(
        configuration: BroadcastWidgetConfiguration,
        logoURL: URL?,
        isEditing: Bool,
        isLive: Bool,
        allowsMotion: Bool = true,
        placement: Binding<BroadcastWidgetPlacement>,
        onLiveSequenceEnded: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.logoURL = logoURL
        self.isEditing = isEditing
        self.isLive = isLive
        self.allowsMotion = allowsMotion
        self._placement = placement
        self.onLiveSequenceEnded = onLiveSequenceEnded
    }

    private var contentSizing: WidgetOverlayContentSizing {
        switch configuration.resolvedTemplate {
        case .animatedLogo, .logo:
            return .uniformSquare
        default:
            return .fillFrame
        }
    }

    private var logoAspectRatio: CGFloat {
        BroadcastWidgetImageLoader.aspectRatio(for: logoURL) ?? 1
    }

    public var body: some View {
        BroadcastDraggableWidgetOverlay(
            placement: $placement,
            isEditing: isEditing,
            contentSizing: contentSizing,
            contentAspectRatio: logoAspectRatio
        ) {
            BroadcastWidgetContentView(
                configuration: configuration,
                logoURL: logoURL,
                isLive: isLive,
                allowsMotion: allowsMotion,
                onLiveSequenceEnded: onLiveSequenceEnded
            )
        }
    }
}
