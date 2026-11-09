import SwiftUI
import EasyStreamCore

/// Studio preview of the Lyriora plate. The program output is the Metal sprite, not this view.
struct LyrioraWidgetView: View {
    let configuration: BroadcastWidgetConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shownBody = ""
    @State private var plateVisible = false

    private var frame: LyrioraAirFrame { LyrioraAirFeed.shared.frame }
    private var isFullScreen: Bool { configuration.resolvedLyrioraMode == .fullScreen }

    var body: some View {
        LyrioraWidgetPlateView(
            configuration: configuration,
            headline: frame.headline,
            bodyText: shownBody,
            showsPlaceholder: !frame.hasText
        )
        .opacity(plateVisible || !frame.hasText ? 1 : 0)
        .offset(y: plateVisible || !frame.hasText ? 0 : (isFullScreen ? 18 : 36))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            shownBody = frame.verseBody
            plateVisible = frame.hasText
        }
        .onChange(of: frame.verseBody) { _, newBody in
            if isFullScreen {
                reveal(newBody)
            } else {
                shownBody = newBody
                plateVisible = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        let lines = [frame.headline, frame.verseBody].filter { !$0.isEmpty }.joined(separator: ", ")
        if lines.isEmpty { return LyrioraAirFeed.shared.statusTitle }
        return "\(LyrioraAirFeed.shared.statusTitle). \(lines)"
    }

    private func reveal(_ body: String) {
        let animation: Animation = reduceMotion
            ? .easeOut(duration: 0.2)
            : .easeInOut(duration: isFullScreen ? 0.55 : 0.4)
        withAnimation(animation) {
            plateVisible = false
        } completion: {
            shownBody = body
            withAnimation(animation) {
                plateVisible = !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        }
    }
}
