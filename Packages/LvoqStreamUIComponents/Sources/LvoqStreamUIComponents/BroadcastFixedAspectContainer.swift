import SwiftUI

/// Sizes content to a fixed aspect ratio without letting video views expand the parent layout.
public struct BroadcastFixedAspectContainer<Content: View>: View {
    private let ratio: CGFloat
    @ViewBuilder private let content: () -> Content

    public init(_ ratio: CGFloat = 16 / 9, @ViewBuilder content: @escaping () -> Content) {
        self.ratio = ratio
        self.content = content
    }

    public var body: some View {
        BroadcastAspectRatioLayout(ratio: ratio) {
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}
