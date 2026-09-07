import SwiftUI
import EasyStreamCore

public struct ProgramAudioSourcePanel: View {
    public struct SourceOption: Identifiable, Equatable {
        public let id: CameraSourceID
        public let name: String
        public let isConnected: Bool

        public init(id: CameraSourceID, name: String, isConnected: Bool) {
            self.id = id
            self.name = name
            self.isConnected = isConnected
        }
    }

    let sources: [SourceOption]
    let programAudioSourceID: CameraSourceID?
    let onSelect: (CameraSourceID) -> Void

    public init(
        sources: [SourceOption],
        programAudioSourceID: CameraSourceID?,
        onSelect: @escaping (CameraSourceID) -> Void
    ) {
        self.sources = sources
        self.programAudioSourceID = programAudioSourceID
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("El audio de programa se toma de la cámara seleccionada. El video puede estar en otra fuente.")
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)

            if sources.isEmpty {
                BroadcastInspectorEmptyState("Sin fuentes de audio", systemImage: "mic.slash")
            } else {
                ForEach(sources) { source in
                    Button {
                        onSelect(source.id)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: source.id == programAudioSourceID ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(source.id == programAudioSourceID ? BroadcastTheme.audioGold : BroadcastTheme.subtleText)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(source.name)
                                    .font(.subheadline.weight(.medium))
                                Text(source.isConnected ? "Conectada" : "Desconectada")
                                    .font(.caption2)
                                    .foregroundStyle(BroadcastTheme.subtleText)
                            }

                            Spacer()

                            if source.id == programAudioSourceID {
                                BroadcastTallyPill(BroadcastTerminology.audioShort, color: BroadcastTheme.audioGold)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            source.id == programAudioSourceID
                                ? BroadcastTheme.audioGold.opacity(0.12)
                                : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
