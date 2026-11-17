import SwiftUI

/// Hard-clamps switcher tiles so WebRTC intrinsic sizes cannot stretch an HStack row.
public struct BroadcastFixedTileSlot<Content: View>: View {
    private let size: CGSize
    @ViewBuilder private let content: Content

    public init(width: CGFloat, height: CGFloat, @ViewBuilder content: () -> Content) {
        size = CGSize(width: width, height: height)
        self.content = content()
    }

    public var body: some View {
        BroadcastFixedSizeLayout(width: size.width, height: size.height) {
            content
        }
        .clipped()
    }
}
