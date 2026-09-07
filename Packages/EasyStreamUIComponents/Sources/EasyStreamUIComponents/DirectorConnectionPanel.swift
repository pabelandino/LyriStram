import SwiftUI
import EasyStreamCore

public struct DirectorConnectionPanel: View {
    let directors: [DiscoveredDevice]
    let selectedDirectorID: UUID?
    let connectedDirectorID: UUID?
    let streamState: StreamConnectionState
    let statusMessage: String
    let onSelect: (DiscoveredDevice) -> Void

    public init(
        directors: [DiscoveredDevice],
        selectedDirectorID: UUID?,
        connectedDirectorID: UUID?,
        streamState: StreamConnectionState,
        statusMessage: String,
        onSelect: @escaping (DiscoveredDevice) -> Void
    ) {
        self.directors = directors
        self.selectedDirectorID = selectedDirectorID
        self.connectedDirectorID = connectedDirectorID
        self.streamState = streamState
        self.statusMessage = statusMessage
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(statusMessage)
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)

            if directors.isEmpty {
                Text("Esperando un Director en la red local…")
                    .font(.caption)
                    .foregroundStyle(BroadcastTheme.subtleText)
            } else if directors.count == 1, let director = directors.first {
                directorRow(director, showsSelector: false)
            } else {
                Text("Director de destino")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BroadcastTheme.subtleText)

                ForEach(directors) { director in
                    Button {
                        onSelect(director)
                    } label: {
                        directorRow(director, showsSelector: true)
                    }
                    .buttonStyle(.plain)
                }

                Text("El video se envía solo al Director seleccionado. El intercom sigue siendo independiente.")
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
        }
    }

    @ViewBuilder
    private func directorRow(_ director: DiscoveredDevice, showsSelector: Bool) -> some View {
        HStack(spacing: 10) {
            if showsSelector {
                Image(systemName: isSelected(director) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected(director) ? BroadcastTheme.studioAccent : BroadcastTheme.subtleText)
            } else {
                Image(systemName: "rectangle.inset.filled.and.person.filled")
                    .foregroundStyle(BroadcastTheme.studioAccent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(director.displayName)
                    .font(.subheadline.weight(.medium))
                Text(director.platform.displayName)
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
            }

            Spacer(minLength: 0)

            connectionBadge(for: director)

            if connectedDirectorID != director.id, !director.isProtocolCompatible {
                Text("Incompatible")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            isSelected(director) ? BroadcastTheme.studioAccent.opacity(0.12) : Color.clear,
            in: RoundedRectangle(cornerRadius: 8)
        )
    }

    private func isSelected(_ director: DiscoveredDevice) -> Bool {
        selectedDirectorID == director.id
            || (selectedDirectorID == nil && connectedDirectorID == director.id)
    }

    @ViewBuilder
    private func connectionBadge(for director: DiscoveredDevice) -> some View {
        let isActiveTarget = connectedDirectorID == director.id
            || (selectedDirectorID == director.id && (streamState == .connecting || streamState == .signaling))

        if isActiveTarget {
            switch streamState {
            case .connected:
                BroadcastTallyPill("En vivo", color: BroadcastTheme.previewGreen)
            case .connecting, .signaling:
                BroadcastTallyPill("Conectando", color: BroadcastTheme.liveAmber)
            case .failed:
                BroadcastTallyPill("Error", color: BroadcastTheme.programRed)
            default:
                EmptyView()
            }
        }
    }
}
