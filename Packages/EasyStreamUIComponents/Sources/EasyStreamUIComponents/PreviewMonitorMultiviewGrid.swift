import SwiftUI
import EasyStreamCore
import WebRTC

public struct PreviewMonitorMultiviewGrid: View {
    let cameras: [PreviewMonitorCamera]
    let previewSourceID: CameraSourceID?
    let programSourceID: CameraSourceID?
    let programAudioSourceID: CameraSourceID?
    let settings: PreviewMonitorSettings
    let currentPage: Int
    let suppressProgramHeroLiveVideo: Bool
    let onSelect: (CameraSourceID) -> Void

    public init(
        cameras: [PreviewMonitorCamera],
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?,
        programAudioSourceID: CameraSourceID?,
        settings: PreviewMonitorSettings,
        currentPage: Int,
        suppressProgramHeroLiveVideo: Bool = true,
        onSelect: @escaping (CameraSourceID) -> Void
    ) {
        self.cameras = cameras
        self.previewSourceID = previewSourceID
        self.programSourceID = programSourceID
        self.programAudioSourceID = programAudioSourceID
        self.settings = settings
        self.currentPage = currentPage
        self.suppressProgramHeroLiveVideo = suppressProgramHeroLiveVideo
        self.onSelect = onSelect
    }

    public var body: some View {
        GeometryReader { geometry in
            let spec = PreviewMultiviewLayoutEngine.gridSpec(
                for: cameras.count,
                mode: settings.layoutMode
            )
            let showHero = settings.layoutMode == .programPlusGrid && settings.overlays.showProgramInGrid
            let pageCount = PreviewMultiviewLayoutEngine.pageCount(
                cameraCount: cameras.count,
                spec: spec,
                includesProgramHero: showHero
            )
            let page = min(max(0, currentPage), max(0, pageCount - 1))
            let pageCameras = pagedCameras(page: page, spec: spec, showHero: showHero)

            VStack(spacing: settings.appearance.cellGap) {
                if showHero, let programID = programSourceID,
                   let programCamera = cameras.first(where: { $0.id == programID }) {
                    PreviewMonitorCellView(
                        camera: programCamera,
                        displayTrack: DirectorPreviewTileTrackPolicy.previewMonitorHeroTrack(
                            for: programCamera.id,
                            track: programCamera.track,
                            programSourceID: programSourceID,
                            suppressProgramHeroLiveVideo: suppressProgramHeroLiveVideo
                        ),
                        settings: settings,
                        isPreview: programID == previewSourceID,
                        isProgram: true,
                        isAudio: programID == programAudioSourceID,
                        onSelect: onSelect
                    )
                    .frame(height: geometry.size.height * 0.42)
                }

                gridBody(
                    cameras: pageCameras,
                    spec: spec,
                    size: geometry.size,
                    showHero: showHero,
                    pageCount: pageCount
                )

                if pageCount > 1 {
                    pageIndicator(page: page, pageCount: pageCount)
                }
            }
            .padding(settings.appearance.cellGap)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(settings.appearance.background.swiftUIColor)
        }
    }

    @ViewBuilder
    private func gridBody(
        cameras pageCameras: [PreviewMonitorCamera],
        spec: PreviewMultiviewGridSpec,
        size: CGSize,
        showHero: Bool,
        pageCount: Int
    ) -> some View {
        let gap = settings.appearance.cellGap
        let rows = settings.layoutMode == .stripHorizontal ? 1 : spec.rows
        let columns = settings.layoutMode == .stripHorizontal ? max(1, pageCameras.count) : spec.columns
        let heroHeight = showHero ? size.height * 0.42 + gap : 0
        let availableHeight = max(0, size.height - heroHeight - gap * 2 - (pageCount > 1 ? 28 : 0))
        let cellWidth = (size.width - gap * Double(columns + 1)) / Double(columns)
        let cellHeight = (availableHeight - gap * Double(rows + 1)) / Double(rows)

        if settings.layoutMode == .stripHorizontal {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: gap) {
                    ForEach(pageCameras) { camera in
                        cell(for: camera)
                            .frame(width: max(180, cellWidth), height: max(100, cellHeight))
                    }
                }
                .padding(.horizontal, gap)
            }
        } else {
            let gridItems = Array(repeating: GridItem(.fixed(max(80, cellWidth)), spacing: gap), count: columns)
            LazyVGrid(columns: gridItems, spacing: gap) {
                ForEach(pageCameras) { camera in
                    cell(for: camera)
                        .frame(width: max(80, cellWidth), height: max(60, cellHeight))
                }
            }
        }
    }

    private var pageCount: Int {
        let spec = PreviewMultiviewLayoutEngine.gridSpec(for: cameras.count, mode: settings.layoutMode)
        let showHero = settings.layoutMode == .programPlusGrid && settings.overlays.showProgramInGrid
        return PreviewMultiviewLayoutEngine.pageCount(
            cameraCount: cameras.count,
            spec: spec,
            includesProgramHero: showHero
        )
    }

    private func pagedCameras(page: Int, spec: PreviewMultiviewGridSpec, showHero: Bool) -> [PreviewMonitorCamera] {
        let reserved = showHero ? 2 : 0
        let capacity = max(1, spec.pageCapacity - reserved)
        let start = page * capacity
        guard start < cameras.count else { return [] }
        let end = min(start + capacity, cameras.count)
        return Array(cameras[start..<end])
    }

    private func cell(for camera: PreviewMonitorCamera) -> some View {
        PreviewMonitorCellView(
            camera: camera,
            displayTrack: DirectorPreviewTileTrackPolicy.previewMonitorGridTrack(
                for: camera.id,
                track: camera.track,
                previewSourceID: previewSourceID,
                programSourceID: programSourceID
            ),
            settings: settings,
            isPreview: camera.id == previewSourceID,
            isProgram: camera.id == programSourceID,
            isAudio: camera.id == programAudioSourceID,
            onSelect: onSelect
        )
    }

    private func pageIndicator(page: Int, pageCount: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == page ? Color.white : Color.white.opacity(0.25))
                    .frame(width: 8, height: 8)
            }
            Text("Página \(page + 1)/\(pageCount)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

}
