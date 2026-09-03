import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Switcher column isolated from sidebar tab changes so WebRTC video keeps rendering smoothly.
struct DirectorSwitcherColumnView: View {
    let viewModel: DirectorSessionViewModel
    let mediaViewModel: BroadcastMediaViewModel
    @Bindable var liveProgramAir: LiveProgramAirStore

    var body: some View {
        VStack(spacing: 0) {
            DirectorStatusBar(
                connectedCameras: viewModel.connectedSourceCount,
                programName: programDisplayName,
                isLive: viewModel.connectedSourceCount > 0,
                encoderStats: viewModel.encoderStats,
                audioEncoderStats: viewModel.audioEncoderStats
            )

            DirectorMainSwitcherAreaView(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                liveProgramAir: liveProgramAir
            )
            .layoutPriority(1)

            DirectorTakeBarView(
                viewModel: viewModel,
                canTake: canTake
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BroadcastTheme.panelBackground)
    }

    private var programDisplayName: String? {
        guard let id = viewModel.programSourceID else { return nil }
        return viewModel.sources.first { $0.id == id }?.displayName
    }

    private var canTake: Bool {
        guard let preview = viewModel.previewSourceID else { return false }
        if let program = viewModel.programSourceID, preview == program { return false }
        return viewModel.connectionState(for: preview) == .connected
    }
}

/// Program monitor + preview grid.
private struct DirectorMainSwitcherAreaView: View {
    let viewModel: DirectorSessionViewModel
    let mediaViewModel: BroadcastMediaViewModel
    @Bindable var liveProgramAir: LiveProgramAirStore

    var body: some View {
        VStack(spacing: 16) {
            DirectorPreviewGridView(viewModel: viewModel)
                .frame(height: 220)

            DirectorProgramOutputCorePanel(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                liveProgramAir: liveProgramAir
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                DirectorProgramPreviewOverlayView(mediaViewModel: mediaViewModel)
            }
            .overlay {
                DirectorProgramStudioHintsOverlay(mediaViewModel: mediaViewModel)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.92))
        .clipped()
#if os(macOS)
        .focusable()
        .focusEffectDisabled(mediaViewModel.isWidgetPlacementEditing)
        .onKeyPress(.space) {
            guard !mediaViewModel.isWidgetPlacementEditing else { return .ignored }
            guard canTake, !viewModel.isTransitioning else { return .ignored }
            viewModel.takeToProgram()
            return .handled
        }
#endif
    }

    private var canTake: Bool {
        guard let preview = viewModel.previewSourceID else { return false }
        if let program = viewModel.programSourceID, preview == program { return false }
        return viewModel.connectionState(for: preview) == .connected
    }
}

private struct DirectorPreviewGridView: View {
    let viewModel: DirectorSessionViewModel

    private let compactTileSize = CGSize(width: 148, height: 84)
    private let expandedTileSize = CGSize(width: 264, height: 149)
    private let tileAnimation = Animation.spring(response: 0.42, dampingFraction: 0.78)

    @State private var expandedSourceID: CameraSourceID?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(BroadcastTerminology.previewName.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if viewModel.sources.isEmpty {
                ContentUnavailableView("Sin cámaras", systemImage: "video.slash")
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(alignment: .center, spacing: 12) {
                            ForEach(viewModel.sources) { source in
                                let isExpanded = expandedSourceID == source.id
                                let tileSize = isExpanded ? expandedTileSize : compactTileSize

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
                                    onSelect: { selectSource(source.id, scrollProxy: proxy) }
                                )
                                .frame(width: tileSize.width, height: tileSize.height)
                                .scaleEffect(isExpanded ? 1 : 0.98)
                                .shadow(
                                    color: isExpanded ? BroadcastTheme.previewGreen.opacity(0.35) : .clear,
                                    radius: isExpanded ? 14 : 0,
                                    y: isExpanded ? 4 : 0
                                )
                                .zIndex(isExpanded ? 1 : 0)
                                .id(source.id)
                            }
                        }
                        .padding(.vertical, 6)
                        .animation(tileAnimation, value: expandedSourceID)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }

    private func selectSource(_ sourceID: CameraSourceID, scrollProxy: ScrollViewProxy) {
        withAnimation(tileAnimation) {
            if expandedSourceID == sourceID {
                expandedSourceID = nil
            } else {
                expandedSourceID = sourceID
            }
        }
        viewModel.selectPreview(sourceID)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(tileAnimation) {
                scrollProxy.scrollTo(sourceID, anchor: .center)
            }
        }
    }
}

/// Program monitor chrome + live feed — no dependency on widget draft state.
private struct DirectorProgramOutputCorePanel: View {
    let viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    @Bindable var liveProgramAir: LiveProgramAirStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(BroadcastTerminology.programName.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            DirectorProgramLiveMonitorView(
                viewModel: viewModel,
                liveProgramAir: liveProgramAir,
                studioPreviewWidgetID: mediaViewModel.isWidgetStudioOpen
                    ? mediaViewModel.editingWidgetResource?.id
                    : nil
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .animation(nil, value: viewModel.isTransitioning)
            .animation(nil, value: viewModel.transitionProgress)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.red, lineWidth: 3)
            }
            .overlay(alignment: .topLeading) {
                if let name = programDisplayName {
                    Text("\(BroadcastTerminology.programShort) · \(name)")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.red, in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(.white)
                        .padding(12)
                }
            }
        }
    }

    private var programDisplayName: String? {
        guard let id = viewModel.programSourceID else { return nil }
        return viewModel.sources.first { $0.id == id }?.displayName
    }
}

private struct DirectorTakeBarView: View {
    @Bindable var viewModel: DirectorSessionViewModel
    let canTake: Bool

    var body: some View {
        VStack(spacing: 12) {
            SwitchTransitionControls(transition: $viewModel.selectedTransition)
                .padding(.horizontal, 16)

            TakeToProgramButton(isEnabled: canTake && !viewModel.isTransitioning) {
                viewModel.takeToProgram()
            }
            .padding(.horizontal, 16)

            Text(BroadcastTerminology.takeDescription + " · El audio de programa permanece en su fuente asignada")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .background(.bar)
    }
}
