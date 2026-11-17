import SwiftUI

enum BroadcastWidgetStudioSharedControls {
    @ViewBuilder
    static func colorWellRow(_ title: String, optionalHex: Binding<String?>, fallback: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
            Spacer()
            BroadcastHexColorWell(optionalHex: optionalHex, supportsOpacity: true, fallback: fallback)
        }
    }

    @ViewBuilder
    static func gradientColorRow(_ title: String, hex: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.caption)
            Spacer()
            BroadcastHexColorWell(hex: hex, supportsOpacity: false)
        }
    }
}
