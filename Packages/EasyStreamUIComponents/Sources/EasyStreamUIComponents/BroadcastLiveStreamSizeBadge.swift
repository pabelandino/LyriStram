import SwiftUI
import EasyStreamCore

/// Small monospaced badge showing live decoded stream dimensions.
public struct BroadcastLiveStreamSizeBadge: View {
    let text: String?
    var tint: Color = BroadcastTheme.subtleText

    public init(_ text: String?, tint: Color = BroadcastTheme.subtleText) {
        self.text = text
        self.tint = tint
    }

    public var body: some View {
        if let text {
            Text(text)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.92))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.black.opacity(0.62), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(tint.opacity(0.35), lineWidth: 0.5)
                }
        }
    }
}

/// PROG / incoming bus dimensions from Metal frame telemetry (live decode, not presets).
public struct ProgramBusLiveResolutionBadge: View {
    public init() {}

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 2.0)) { _ in
            let lines = Self.liveLabels()
            if !lines.isEmpty {
                VStack(alignment: .trailing, spacing: 3) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                        BroadcastLiveStreamSizeBadge(line.text, tint: line.tint)
                    }
                }
            }
        }
    }

    private struct LiveLabel {
        let text: String
        let tint: Color
    }

    private static func liveLabels() -> [LiveLabel] {
        let telemetry = ProgramFrameTelemetryRegistry.live.snapshot()
        var lines: [LiveLabel] = []

        if let prog = telemetry.first(where: { $0.busSlot == .programOnAir }),
           prog.contentSize.width > 1, prog.contentSize.height > 1 {
            let size = "\(Int(prog.contentSize.width))×\(Int(prog.contentSize.height))"
            lines.append(LiveLabel(text: "PROG \(size)", tint: BroadcastTheme.programRed))
        }

        if let incoming = telemetry.first(where: { $0.busSlot == .programIncoming }),
           incoming.contentSize.width > 1, incoming.contentSize.height > 1 {
            let size = "\(Int(incoming.contentSize.width))×\(Int(incoming.contentSize.height))"
            lines.append(LiveLabel(text: "PVW \(size)", tint: BroadcastTheme.previewGreen))
        }

        return lines
    }
}
