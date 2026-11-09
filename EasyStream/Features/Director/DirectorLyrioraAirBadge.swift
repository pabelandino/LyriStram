import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Director-only mark. It is not drawn into the program sprite.
struct DirectorLyrioraAirBadge: View {
    var feed = LyrioraAirFeed.shared

    var body: some View {
        LyrioraAirStatusBadge(title: feed.statusTitle, isOnAir: feed.isOnAir)
            .padding(8)
            .allowsHitTesting(false)
    }
}
