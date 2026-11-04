import SwiftUI
import EasyStreamCore

struct LowerThirdProWidgetView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let isLive: Bool
    let allowsMotion: Bool
    var onLiveSequenceEnded: (() -> Void)?

    @Environment(\.logoMotionEpoch) private var motionEpoch
    @State private var logoOn = true
    @State private var barsOn = [true, true, true]

    var body: some View {
        GeometryReader { geo in
            let fitted = LowerThirdLayout.fittedSize(in: geo.size)
            stage
                .frame(width: fitted.width, height: fitted.height)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .onChange(of: playToken, initial: true) { _, _ in
            prepare()
        }
        .task(id: playToken) {
            await runSequence()
        }
    }

    @ViewBuilder
    private var stage: some View {
        switch configuration.resolvedLowerThirdStyle {
        case .angular:
            LowerThirdAngularBarsView(
                configuration: configuration,
                logoURL: logoURL,
                logoShown: logoOn,
                barsShown: barsOn
            )
        case .titlePlate:
            LowerThirdTitlePlateView(
                configuration: configuration,
                logoURL: logoURL,
                logoShown: logoOn,
                barsShown: barsOn
            )
        case .guest, .guestPlain:
            LowerThirdGuestPlateView(
                configuration: configuration,
                logoURL: logoURL,
                logoShown: logoOn,
                barsShown: barsOn
            )
        }
    }

    private var playToken: String {
        let third = configuration.lowerThirdThirdLine
        return "\(allowsMotion)-\(configuration.autoPlaySequence)-\(configuration.resolvedLowerThirdStyle.rawValue)-\(third)-\(motionEpoch.timeIntervalSinceReferenceDate)"
    }

    private var shouldAnimate: Bool {
        allowsMotion && configuration.autoPlaySequence
    }

    private var sequence: LowerThirdSequence {
        LowerThirdSequence.make(
            style: configuration.resolvedLowerThirdStyle,
            hasThirdLine: !configuration.lowerThirdThirdLine.isEmpty,
            animateIn: configuration.animateInSeconds,
            hold: configuration.holdDurationSeconds,
            animateOut: configuration.animateOutSeconds
        )
    }

    private func prepare() {
        if shouldAnimate {
            logoOn = false
            barsOn = [false, false, false]
        } else {
            logoOn = true
            barsOn = [true, true, true]
        }
    }

    private func runSequence() async {
        guard shouldAnimate else { return }
        do {
            try await Task.sleep(for: .milliseconds(40))
        } catch {
            return
        }
        guard !Task.isCancelled else { return }

        let timeline = sequence
        let start = Date()
        guard await wait(until: timeline.logo.enterDelay, from: start) else { return }
        withAnimation(.easeOut(duration: timeline.logo.enterDuration)) {
            logoOn = true
        }
        for index in timeline.bars.indices {
            guard await wait(until: timeline.bars[index].enterDelay, from: start) else { return }
            let duration = timeline.bars[index].enterDuration
            withAnimation(.easeOut(duration: duration)) {
                barsOn[index] = true
            }
        }
        for index in timeline.bars.indices {
            guard await wait(until: timeline.bars[index].exitDelay, from: start) else { return }
            let duration = timeline.bars[index].exitDuration
            withAnimation(.easeIn(duration: duration)) {
                barsOn[index] = false
            }
        }
        guard await wait(until: timeline.logo.exitDelay, from: start) else { return }
        withAnimation(.easeIn(duration: timeline.logo.exitDuration)) {
            logoOn = false
        }
        guard await wait(until: timeline.totalDuration, from: start) else { return }
        if isLive {
            onLiveSequenceEnded?()
            return
        }
        do {
            try await Task.sleep(for: .milliseconds(280))
        } catch {
            return
        }
        logoOn = true
        barsOn = [true, true, true]
    }

    private func wait(until delay: Double, from start: Date) async -> Bool {
        let remain = delay - Date().timeIntervalSince(start)
        if remain > 0.01 {
            do {
                try await Task.sleep(for: .seconds(remain))
            } catch {
                return false
            }
        }
        return !Task.isCancelled
    }
}
