import SwiftUI
import EasyStreamCore

public struct BroadcastResourceRow: View {
    let resource: BroadcastResource
    let fileURL: URL
    let isActive: Bool
    let isLiveOnAir: Bool
    let onSelect: () -> Void
    let onEdit: (() -> Void)?
    let onTakeToProgram: () -> Void
    let onRemoveFromProgram: (() -> Void)?
    let onRename: () -> Void
    let onDelete: () -> Void

    public init(
        resource: BroadcastResource,
        fileURL: URL,
        isActive: Bool,
        isLiveOnAir: Bool = false,
        onSelect: @escaping () -> Void,
        onEdit: (() -> Void)?,
        onTakeToProgram: @escaping () -> Void,
        onRemoveFromProgram: (() -> Void)? = nil,
        onRename: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.resource = resource
        self.fileURL = fileURL
        self.isActive = isActive
        self.isLiveOnAir = isLiveOnAir
        self.onSelect = onSelect
        self.onEdit = onEdit
        self.onTakeToProgram = onTakeToProgram
        self.onRemoveFromProgram = onRemoveFromProgram
        self.onRename = onRename
        self.onDelete = onDelete
    }

    public var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 6) {
                BroadcastResourceThumbnail(resource: resource, fileURL: fileURL)
                    .frame(width: 44, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 5))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(resource.listLabel)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                            .truncationMode(.tail)

                        if isLiveOnAir {
                            BroadcastCompactLiveBadge()
                        }
                    }

                    Text(resource.kind.title)
                        .font(.caption2)
                        .foregroundStyle(BroadcastTheme.subtleText)
                        .lineLimit(1)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)

            airButton

            if let onEdit {
                rowIconButton(
                    systemImage: "slider.horizontal.3",
                    help: "Editar en Widget Studio",
                    action: onEdit
                )
            } else {
                overflowMenu
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            isActive ? BroadcastTheme.programRed.opacity(0.12) : BroadcastTheme.panelElevated,
            in: RoundedRectangle(cornerRadius: 8)
        )
    }

    private var overflowMenu: some View {
        Menu {
            Button("Seleccionar") { onSelect() }
            if isLiveOnAir, let onRemoveFromProgram {
                Button("Quitar del aire", role: .destructive) { onRemoveFromProgram() }
            } else {
                Button("Al aire") { onTakeToProgram() }
            }
            Button("Renombrar") { onRename() }
            Divider()
            Button("Eliminar", role: .destructive) { onDelete() }
        } label: {
            Image(systemName: "ellipsis")
                .font(.body.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)
                .frame(width: 22, height: 22)
                .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    private var airButton: some View {
        rowIconButton(
            systemImage: isLiveOnAir ? "minus.circle" : "dot.radiowaves.left.and.right",
            help: isLiveOnAir ? "Quitar del aire" : "Al aire",
            tint: isLiveOnAir ? BroadcastTheme.programRed : BroadcastTheme.liveAmber,
            action: {
                if isLiveOnAir {
                    onRemoveFromProgram?()
                } else {
                    onTakeToProgram()
                }
            }
        )
    }

    private func rowIconButton(
        systemImage: String,
        help: String,
        tint: Color = BroadcastTheme.subtleText,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 22, height: 22)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .fixedSize()
        .help(help)
        .accessibilityLabel(help)
    }
}

fileprivate struct BroadcastResourceThumbnail: View {
    let resource: BroadcastResource
    let fileURL: URL

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(BroadcastTheme.panelBackground)
            switch resource.kind {
            case .image:
                BroadcastAsyncThumbnailImage(url: fileURL)
            case .video:
                Image(systemName: "film")
                    .foregroundStyle(BroadcastTheme.subtleText)
            case .widget:
                Image(systemName: "rectangle.3.group")
                    .foregroundStyle(BroadcastTheme.audioGold)
            }
        }
        .clipped()
    }
}

/// Loads library thumbnails off the main thread with downscaled ImageIO decode + cache.
fileprivate struct BroadcastAsyncThumbnailImage: View {
    let url: URL
    @State private var image: Image?

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .task(id: url) {
            if let cached = BroadcastMediaThumbnailLoader.cachedImage(for: url) {
                image = cached
                return
            }
            image = await BroadcastMediaThumbnailLoader.loadThumbnail(from: url)
        }
    }
}
