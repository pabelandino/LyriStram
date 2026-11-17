import SwiftUI

/// Loads widget logos asynchronously; image is held in @State so TimelineView ticks do not hit disk.
public struct CachedWidgetLogoView: View {
    let logoURL: URL?
    private let contentBuilder: (Image) -> AnyView
    private let placeholderBuilder: () -> AnyView

    @State private var loadedImage: Image?

    public init<Content: View, Placeholder: View>(
        logoURL: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.logoURL = logoURL
        self.contentBuilder = { AnyView(content($0)) }
        self.placeholderBuilder = { AnyView(placeholder()) }
    }

    public var body: some View {
        Group {
            if let loadedImage {
                contentBuilder(loadedImage)
            } else {
                placeholderBuilder()
            }
        }
        .task(id: logoURL) {
            guard let logoURL else {
                loadedImage = nil
                return
            }
            if let cached = BroadcastWidgetImageLoader.load(url: logoURL) {
                loadedImage = cached
                return
            }
            let url = logoURL
            loadedImage = await Task.detached(priority: .utility) {
                BroadcastWidgetImageLoader.loadAndCache(url: url)
            }.value
        }
    }
}
