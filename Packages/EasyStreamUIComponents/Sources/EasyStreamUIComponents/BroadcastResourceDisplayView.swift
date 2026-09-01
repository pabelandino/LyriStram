import AVKit
import SwiftUI
import EasyStreamCore

public struct BroadcastResourceDisplayView: View {
    let resource: BroadcastResource
    let fileURL: URL
    let widgetConfiguration: BroadcastWidgetConfiguration?
    let logoURL: URL?
    let isLive: Bool
    let isEditingWidget: Bool
    @Binding var widgetPlacement: BroadcastWidgetPlacement

    public init(
        resource: BroadcastResource,
        fileURL: URL,
        widgetConfiguration: BroadcastWidgetConfiguration? = nil,
        logoURL: URL? = nil,
        isLive: Bool = true,
        isEditingWidget: Bool = false,
        widgetPlacement: Binding<BroadcastWidgetPlacement> = .constant(BroadcastWidgetPlacement())
    ) {
        self.resource = resource
        self.fileURL = fileURL
        self.widgetConfiguration = widgetConfiguration
        self.logoURL = logoURL
        self.isLive = isLive
        self.isEditingWidget = isEditingWidget
        self._widgetPlacement = widgetPlacement
    }

    public var body: some View {
        Group {
            switch resource.kind {
            case .image:
                BroadcastAsyncImageResourceView(url: fileURL)
            case .video:
                BroadcastVideoResourceView(url: fileURL)
            case .widget:
                if let widgetConfiguration {
                    BroadcastWidgetCanvas(
                        configuration: widgetConfiguration,
                        logoURL: logoURL,
                        isEditing: isEditingWidget,
                        isLive: isLive,
                        placement: $widgetPlacement
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct BroadcastAsyncImageResourceView: View {
    let url: URL
    @State private var image: Image?

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .task(id: url) {
            image = await BroadcastMediaThumbnailLoader.loadPreviewImage(from: url)
        }
    }
}

private struct BroadcastVideoResourceView: View {
    let url: URL
    @State private var player: AVPlayer?

    var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
                    .onDisappear { player.pause() }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            let player = AVPlayer(url: url)
            player.play()
            self.player = player
        }
    }
}

#if os(macOS)
import AppKit
#else
import UIKit
#endif
