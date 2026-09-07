import SwiftUI
import EasyStreamCore

struct CountdownWidgetView: View {
    let configuration: BroadcastWidgetConfiguration
    let isLive: Bool

    @State private var remainingSeconds: Int = 0
    @State private var animateToken = 0

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let _ = tick(context.date)
            Text(formattedRemaining)
                .font(BroadcastWidgetTypography.font(
                    configuration.titleFont,
                    size: configuration.titleFontSize,
                    weight: .bold
                ))
                .foregroundStyle(BroadcastWidgetColors.color(hex: configuration.accentColorHex))
                .shadow(color: .black.opacity(0.45), radius: 10)
                .modifier(CountdownAnimationModifier(
                    style: configuration.countdownAnimation,
                    token: animateToken
                ))
                .onChange(of: formattedRemaining) { _, _ in
                    animateToken += 1
                }
        }
        .onAppear { syncRemaining() }
        .onChange(of: configuration.countdownSeconds) { _, _ in syncRemaining() }
        .onChange(of: configuration.countdownTargetDate) { _, _ in syncRemaining() }
    }

    private var formattedRemaining: String {
        let seconds = max(0, remainingSeconds)
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func syncRemaining() {
        if let target = configuration.countdownTargetDate {
            remainingSeconds = max(0, Int(target.timeIntervalSinceNow))
        } else if remainingSeconds == 0 {
            remainingSeconds = max(0, configuration.countdownSeconds)
        }
    }

    private func tick(_ date: Date) {
        if let target = configuration.countdownTargetDate {
            remainingSeconds = max(0, Int(target.timeIntervalSinceNow))
        } else if isLive, remainingSeconds > 0 {
            remainingSeconds -= 1
        } else if !isLive {
            remainingSeconds = max(0, configuration.countdownSeconds)
        }
    }
}

struct CountdownAnimationModifier: ViewModifier {
    let style: BroadcastCountdownAnimation
    let token: Int

    @State private var animate = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(y: offsetY)
            .rotation3DEffect(.degrees(flipDegrees), axis: (x: 1, y: 0, z: 0))
            .onChange(of: token) { _, _ in
                animate = false
                withAnimation(animation) { animate = true }
            }
            .onAppear {
                withAnimation(animation) { animate = true }
            }
    }

    private var animation: Animation {
        switch style {
        case .fadeScale: .spring(response: 0.45, dampingFraction: 0.72)
        case .flipClock: .easeInOut(duration: 0.35)
        case .slideUp: .spring(response: 0.5, dampingFraction: 0.8)
        case .bounce: .interpolatingSpring(stiffness: 220, damping: 12)
        }
    }

    private var scale: CGFloat {
        guard style == .fadeScale || style == .bounce else { return 1 }
        return animate ? 1 : (style == .bounce ? 1.15 : 0.82)
    }

    private var opacity: Double {
        style == .fadeScale ? (animate ? 1 : 0.25) : 1
    }

    private var offsetY: CGFloat {
        style == .slideUp ? (animate ? 0 : 28) : 0
    }

    private var flipDegrees: Double {
        style == .flipClock ? (animate ? 0 : 90) : 0
    }
}
