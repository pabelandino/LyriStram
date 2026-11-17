import SwiftUI
import LvoqStreamCore

struct DirectorRemoteZoomControl: View {
    let zoomFactor: Double
    let onZoomChange: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(BundleLocalization.string("common.zoom"))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(String(format: "%.1fx", zoomFactor))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
            Slider(
                value: Binding(get: { zoomFactor }, set: { onZoomChange($0) }),
                in: 1...10
            )
        }
    }
}
