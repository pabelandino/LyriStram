import SwiftUI
import LvoqStreamCore
import LvoqStreamUIComponents

/// Director-only mark. It is not drawn into the program sprite.
struct DirectorLvoqShowAirBadge: View {
    var feed = LvoqShowAirFeed.shared

    var body: some View {
        LvoqShowAirStatusBadge(title: feed.statusTitle, isOnAir: feed.isOnAir)
            .padding(8)
            .allowsHitTesting(false)
    }
}
