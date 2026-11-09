import SwiftUI

/// Small green lamp on the Lyriora plate. The program picture draws the same lamp in the sprite.
struct LyrioraWidgetLiveNeon: View {
    var body: some View {
        Circle()
            .fill(Color(red: 0.78, green: 1, blue: 0.85))
            .frame(width: 8, height: 8)
            .shadow(color: Color(red: 0.24, green: 1, blue: 0.54).opacity(0.85), radius: 6)
            .accessibilityHidden(true)
    }
}
