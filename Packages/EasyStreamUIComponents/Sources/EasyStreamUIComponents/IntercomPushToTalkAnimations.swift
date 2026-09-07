import SwiftUI

struct IntercomActivationRing: View {
    let cornerRadius: CGFloat

    @State private var rotation: Double = 0

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                AngularGradient(
                    colors: [
                        BroadcastTheme.studioAccent.opacity(0.15),
                        BroadcastTheme.studioAccent,
                        BroadcastTheme.controlAccent,
                        BroadcastTheme.studioAccent.opacity(0.15),
                    ],
                    center: .center
                ),
                lineWidth: 3
            )
            .rotationEffect(.degrees(rotation))
            .shadow(color: BroadcastTheme.studioAccent.opacity(0.55), radius: 10)
            .allowsHitTesting(false)
            .onAppear {
                rotation = 0
                withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

struct IntercomPushToTalkPulseRings: View {
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                IntercomPushToTalkPulseRing(cornerRadius: cornerRadius, delay: Double(index) * 0.28)
            }
        }
        .allowsHitTesting(false)
    }
}

struct IntercomPushToTalkPulseRing: View {
    let cornerRadius: CGFloat
    let delay: Double

    @State private var isPulsing = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(BroadcastTheme.programRed.opacity(0.75), lineWidth: 2.5)
            .scaleEffect(isPulsing ? 1.18 : 1)
            .opacity(isPulsing ? 0 : 0.85)
            .onAppear { startPulsing() }
    }

    private func startPulsing() {
        isPulsing = false
        withAnimation(.easeOut(duration: 1.05).repeatForever(autoreverses: false).delay(delay)) {
            isPulsing = true
        }
    }
}
