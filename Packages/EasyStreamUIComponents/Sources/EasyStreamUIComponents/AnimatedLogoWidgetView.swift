import SwiftUI
import EasyStreamCore

enum LogoAnimationCycle {
    static func state(time: TimeInterval, speed: Double) -> (isActive: Bool, progress: Double, idlePhase: Double) {
        let cycleDuration = max(3.5, 5.0 / speed)
        let activeDuration = min(1.4 / speed, cycleDuration * 0.35)
        let t = time.truncatingRemainder(dividingBy: cycleDuration)
        let idlePhase = time * 0.15
        if t < activeDuration {
            return (true, t / activeDuration, idlePhase)
        }
        return (false, 0, idlePhase)
    }
}

struct AnimatedLogoWidgetView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let allowsMotion: Bool

    var body: some View {
        CachedWidgetLogoView(logoURL: logoURL) { image in
            LogoMotionContainer(
                allowsMotion: allowsMotion,
                configuration: configuration,
                content: image
                    .resizable()
                    .scaledToFit()
            )
        } placeholder: {
            LogoMotionContainer(
                allowsMotion: allowsMotion,
                configuration: configuration,
                content: placeholderLogo
            )
        }
    }

    private var placeholderLogo: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(BroadcastWidgetColors.color(hex: configuration.accentColorHex).opacity(0.35))
            .overlay {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.8))
            }
    }
}

struct LogoMotionContainer<Content: View>: View {
    let allowsMotion: Bool
    let configuration: BroadcastWidgetConfiguration
    let content: Content

    var body: some View {
        if allowsMotion {
            TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate * configuration.animationSpeed
                content
                    .modifier(LogoAnimationModifier(
                        kind: configuration.logoAnimation,
                        time: time,
                        speed: configuration.animationSpeed
                    ))
            }
        } else {
            content
        }
    }
}

struct LogoAnimationModifier: ViewModifier {
    let kind: BroadcastLogoAnimation
    let time: TimeInterval
    let speed: Double

    private var anim: (isActive: Bool, progress: Double, idlePhase: Double) {
        LogoAnimationCycle.state(time: time, speed: speed)
    }

    func body(content: Content) -> some View {
        let state = anim
        switch kind {
        case .none:
            content
        case .rotate:
            content
                .rotationEffect(.degrees(state.isActive ? state.progress * 360 : sin(state.idlePhase) * 3))
        case .sphere3D:
            sphereContent(content, state: state)
        case .pulse:
            content
                .scaleEffect(state.isActive ? 1.0 + sin(state.progress * .pi) * 0.1 : 1.0)
        case .float:
            content
                .offset(y: state.isActive ? sin(state.progress * .pi) * -10 : sin(state.idlePhase) * 2)
        case .flip:
            content
                .rotation3DEffect(
                    .degrees(state.isActive ? state.progress * 360 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.55
                )
        }
    }

    @ViewBuilder
    private func sphereContent(_ content: Content, state: (isActive: Bool, progress: Double, idlePhase: Double)) -> some View {
        let spin = state.isActive ? state.progress * 360 : sin(state.idlePhase) * 6
        let tilt = state.isActive ? sin(state.progress * .pi) * 12 : sin(state.idlePhase * 0.7) * 4
        let radians = spin * .pi / 180
        let depthScale = 0.72 + abs(cos(radians)) * 0.28
        let highlightShift = sin(radians) * 0.08

        content
            .scaledToFill()
            .clipShape(Circle())
            .overlay {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.28 + highlightShift),
                                .clear,
                                .black.opacity(0.22 - highlightShift)
                            ],
                            center: UnitPoint(x: 0.32 - highlightShift, y: 0.28),
                            startRadius: 2,
                            endRadius: 120
                        )
                    )
                    .blendMode(.softLight)
            }
            .overlay {
                Circle()
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            }
            .scaleEffect(x: depthScale, y: 1.0)
            .rotation3DEffect(.degrees(spin), axis: (0, 1, 0), perspective: 0.62)
            .rotation3DEffect(.degrees(tilt), axis: (1, 0, 0), perspective: 0.62)
    }
}
