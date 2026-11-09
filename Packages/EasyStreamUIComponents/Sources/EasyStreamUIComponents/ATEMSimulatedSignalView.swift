import SwiftUI

/// Test picture for an ATEM input. The Switchers SDK does not carry each HDMI or SDI frame.
struct ATEMSimulatedSignalView: View {
    let name: String
    let portTitle: String
    let isSimulated: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: barColors,
                startPoint: .leading,
                endPoint: .trailing
            )
            VStack(spacing: 4) {
                Text(portTitle)
                    .font(.caption2.weight(.heavy))
                Text(name)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Text(isSimulated ? "Simulación" : "Entrada en el ATEM")
                    .font(.caption2)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 4))
        }
        .accessibilityLabel("\(portTitle) \(name)")
    }

    private var barColors: [Color] {
        [
            Color(red: 0.75, green: 0.75, blue: 0.75),
            Color(red: 0.75, green: 0.75, blue: 0.0),
            Color(red: 0.0, green: 0.75, blue: 0.75),
            Color(red: 0.0, green: 0.75, blue: 0.0),
            Color(red: 0.75, green: 0.0, blue: 0.75),
            Color(red: 0.75, green: 0.0, blue: 0.0),
            Color(red: 0.0, green: 0.0, blue: 0.75)
        ]
    }
}
