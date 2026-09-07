import SwiftUI

public struct BroadcastGlassBorderedButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        BroadcastGlowButtonStyle(tint: BroadcastTheme.controlAccent, isProminent: false)
            .makeBody(configuration: configuration)
    }
}
