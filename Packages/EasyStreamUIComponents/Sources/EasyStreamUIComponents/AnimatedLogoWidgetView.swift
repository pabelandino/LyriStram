import SwiftUI
import EasyStreamCore

private struct LogoMotionEpochKey: EnvironmentKey {
    static let defaultValue = Date.distantPast
}

public extension EnvironmentValues {
    /// Restarts the studio preview animation. On-air graphics keep their own clock.
    var logoMotionEpoch: Date {
        get { self[LogoMotionEpochKey.self] }
        set { self[LogoMotionEpochKey.self] = newValue }
    }
}

struct AnimatedLogoWidgetView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let allowsMotion: Bool

    @Environment(\.logoMotionEpoch) private var motionEpoch

    var body: some View {
        LogoCoreMotionView(
            imageURL: logoURL,
            kind: allowsMotion ? configuration.logoAnimation : .none,
            speed: configuration.animationSpeed,
            epoch: allowsMotion ? motionEpoch : .distantPast,
            accentHex: configuration.accentColorHex ?? "888888"
        )
    }
}
