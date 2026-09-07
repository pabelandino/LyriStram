import SwiftUI
import WebRTC
import EasyStreamCore
import EasyStreamUIComponents

enum DirectorPreviewGridMetrics {
    /// Caption + tile row + padding — fixed so PROG monitor never inherits preview layout churn.
    static let bandHeight: CGFloat = 108
    static let tileWidth: CGFloat = 148
    static let tileHeight: CGFloat = 84
}

struct DirectorPreviewGridView: View {
    let viewModel: DirectorSessionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(BroadcastTerminology.previewName.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            if viewModel.sources.isEmpty {
                ContentUnavailableView("Sin cámaras", systemImage: "video.slash")
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: DirectorPreviewGridMetrics.tileHeight)
            } else {
                DirectorPreviewTileScroller(viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
        .animation(nil, value: viewModel.previewSourceID)
        .animation(nil, value: viewModel.programSourceID)
        .transaction { $0.animation = nil }
    }
}

/// Isolated scroller — keeps `ScrollViewReader` identity stable when sources change.
private struct DirectorPreviewTileScroller: View {
    let viewModel: DirectorSessionViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: true) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(viewModel.sources) { source in
                        DirectorPreviewTileCell(
                            source: source,
                            viewModel: viewModel,
                            onSelect: { selectSource(source.id, scrollProxy: proxy) }
                        )
                        .id(source.id)
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(height: DirectorPreviewGridMetrics.tileHeight + 4)
        }
    }

    private func selectSource(_ sourceID: CameraSourceID, scrollProxy: ScrollViewProxy) {
        viewModel.selectPreview(sourceID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            scrollProxy.scrollTo(sourceID, anchor: .center)
        }
    }
}

/// One fixed slot per camera — stable identity for WebRTC surfaces.
private struct DirectorPreviewTileCell: View {
    let source: ConnectedCameraSource
    let viewModel: DirectorSessionViewModel
    let onSelect: () -> Void

    var body: some View {
        BroadcastFixedTileSlot(
            width: DirectorPreviewGridMetrics.tileWidth,
            height: DirectorPreviewGridMetrics.tileHeight
        ) {
            CameraSourceTile(
                name: source.displayName,
                track: DirectorPreviewTileTrackPolicy.liveTileTrack(
                    for: source.id,
                    track: source.videoTrack,
                    previewSourceID: viewModel.previewSourceID,
                    programSourceID: viewModel.programSourceID
                ),
                hasVideoSignal: source.videoTrack != nil,
                connectionState: source.connectionState,
                isPreview: source.id == viewModel.previewSourceID,
                isProgram: source.id == viewModel.programSourceID,
                onSelect: onSelect
            )
        }
    }
}
