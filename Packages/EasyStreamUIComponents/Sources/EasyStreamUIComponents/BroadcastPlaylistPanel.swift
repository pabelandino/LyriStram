import SwiftUI
import EasyStreamCore

public struct BroadcastPlaylistPanel: View {
    let playlists: [BroadcastPlaylist]
    let allResources: [BroadcastResource]
    let activePlaylistID: UUID?
    let isPlaying: Bool
    let queueLabel: String?
    let onCreatePlaylist: () -> Void
    let onEditPlaylist: (BroadcastPlaylist) -> Void
    let onDeletePlaylist: (BroadcastPlaylist) -> Void
    let onPlayPlaylist: (BroadcastPlaylist) -> Void
    let onStopPlayback: () -> Void
    let onPlayNext: () -> Void

    public init(
        playlists: [BroadcastPlaylist],
        allResources: [BroadcastResource],
        activePlaylistID: UUID?,
        isPlaying: Bool,
        queueLabel: String?,
        onCreatePlaylist: @escaping () -> Void,
        onEditPlaylist: @escaping (BroadcastPlaylist) -> Void,
        onDeletePlaylist: @escaping (BroadcastPlaylist) -> Void,
        onPlayPlaylist: @escaping (BroadcastPlaylist) -> Void,
        onStopPlayback: @escaping () -> Void,
        onPlayNext: @escaping () -> Void
    ) {
        self.playlists = playlists
        self.allResources = allResources
        self.activePlaylistID = activePlaylistID
        self.isPlaying = isPlaying
        self.queueLabel = queueLabel
        self.onCreatePlaylist = onCreatePlaylist
        self.onEditPlaylist = onEditPlaylist
        self.onDeletePlaylist = onDeletePlaylist
        self.onPlayPlaylist = onPlayPlaylist
        self.onStopPlayback = onStopPlayback
        self.onPlayNext = onPlayNext
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Playlists para transmisión")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button(action: onCreatePlaylist) {
                    Label("Nueva", systemImage: "plus")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.borderless)
            }

            if isPlaying {
                VStack(alignment: .leading, spacing: 8) {
                    if let queueLabel {
                        Text("Reproduciendo: \(queueLabel)")
                            .font(.caption)
                            .foregroundStyle(BroadcastTheme.subtleText)
                    }
                    HStack {
                        Button("Siguiente", action: onPlayNext)
                        Button("Detener", role: .destructive, action: onStopPlayback)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(10)
                .broadcastPanel()
            }

            if playlists.isEmpty {
                BroadcastInspectorEmptyState("Sin playlists", systemImage: "list.bullet.rectangle")
                    .padding(.vertical, 20)
            } else {
                ForEach(playlists) { playlist in
                    BroadcastPlaylistRow(
                        playlist: playlist,
                        itemCount: resolvedItems(for: playlist).count,
                        isActive: playlist.id == activePlaylistID,
                        onPlay: { onPlayPlaylist(playlist) },
                        onEdit: { onEditPlaylist(playlist) },
                        onDelete: { onDeletePlaylist(playlist) }
                    )
                }
            }
        }
    }

    private func resolvedItems(for playlist: BroadcastPlaylist) -> [BroadcastResource] {
        playlist.itemIDs.compactMap { id in allResources.first { $0.id == id } }
    }
}

private struct BroadcastPlaylistRow: View {
    let playlist: BroadcastPlaylist
    let itemCount: Int
    let isActive: Bool
    let onPlay: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: playlist.kind.systemImage)
                .foregroundStyle(BroadcastTheme.studioAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text(playlist.name)
                    .font(.subheadline.weight(.medium))
                Text("\(itemCount) elemento(s) · \(playlist.kind.title)")
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
            Spacer()
            Button(action: onPlay) {
                Image(systemName: "play.fill")
            }
            .buttonStyle(.borderless)
            Menu {
                Button("Editar", action: onEdit)
                Button("Eliminar", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
        }
        .padding(10)
        .background(
            isActive ? BroadcastTheme.audioGold.opacity(0.12) : BroadcastTheme.panelElevated,
            in: RoundedRectangle(cornerRadius: 8)
        )
    }
}
