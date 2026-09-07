import SwiftUI
import EasyStreamCore

public struct DirectorSourceListRow: View {
    let name: String
    let isPreview: Bool
    let isProgram: Bool
    let isAudio: Bool
    let isConnected: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    let onReconnect: (() -> Void)?

    public init(
        name: String,
        isPreview: Bool,
        isProgram: Bool,
        isAudio: Bool,
        isConnected: Bool,
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        onReconnect: (() -> Void)? = nil
    ) {
        self.name = name
        self.isPreview = isPreview
        self.isProgram = isProgram
        self.isAudio = isAudio
        self.isConnected = isConnected
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.onReconnect = onReconnect
    }

    public var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(accentBarColor)
                    .frame(width: 4)
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BroadcastTheme.primaryText)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        if isPreview {
                            BroadcastTallyPill(BroadcastTerminology.previewShort, color: BroadcastTheme.previewGreen)
                        }
                        if isProgram {
                            BroadcastTallyPill(BroadcastTerminology.programShort, color: BroadcastTheme.programRed)
                        }
                        if isAudio {
                            BroadcastTallyPill(BroadcastTerminology.audioShort, color: BroadcastTheme.audioGold)
                        }
                    }
                }

                Spacer(minLength: 0)

                if !isConnected, let onReconnect {
                    Button(action: onReconnect) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.body)
                            .foregroundStyle(BroadcastTheme.studioAccent)
                    }
                    .buttonStyle(.plain)
                    .help("Reconectar cámara")
                }

                Circle()
                    .fill(isConnected ? BroadcastTheme.previewGreen : Color.orange)
                    .frame(width: 8, height: 8)
                    .shadow(color: isConnected ? BroadcastTheme.previewGreen.opacity(0.6) : .clear, radius: 4)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(rowBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(rowBorder, lineWidth: isSelected ? 1.5 : 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var accentBarColor: Color {
        if isProgram { return BroadcastTheme.programRed }
        if isPreview { return BroadcastTheme.previewGreen }
        return Color.white.opacity(0.15)
    }

    private var rowBackground: Color {
        BroadcastTheme.panelElevated.opacity(isSelected ? 0.95 : 0.55)
    }

    private var rowBorder: Color {
        if isSelected { return BroadcastTheme.previewGreen.opacity(0.55) }
        return BroadcastTheme.panelBorder
    }
}
