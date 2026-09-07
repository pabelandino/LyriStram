import SwiftUI

struct DirectorRemoteExposureControl: View {
    let exposureBias: Float
    let onExposureChange: (Float) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Exposición")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(String(format: "%+.1f EV", exposureBias))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
            Slider(
                value: Binding(
                    get: { Double(exposureBias) },
                    set: { onExposureChange(Float($0)) }
                ),
                in: -2...2
            )
        }
    }
}
