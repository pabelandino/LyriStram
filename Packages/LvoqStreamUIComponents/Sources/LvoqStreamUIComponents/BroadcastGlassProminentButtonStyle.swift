import SwiftUI

public struct BroadcastGlassProminentButtonStyle: ButtonStyle {
    let tint: Color

    public init(tint: Color = BroadcastTheme.controlAccent) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        BroadcastGlowButtonStyle(tint: tint, isProminent: true)
            .makeBody(configuration: configuration)
    }
}
