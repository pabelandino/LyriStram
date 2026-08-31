import Foundation
import Observation
import EasyStreamCore
import EasyStreamUIComponents
import WebRTC

@MainActor
@Observable
final class DirectorPreviewMonitorStore {
    static let shared = DirectorPreviewMonitorStore()

    private(set) var cameras: [PreviewMonitorCamera] = []
    private(set) var previewSourceID: CameraSourceID?
    private(set) var programSourceID: CameraSourceID?
    private(set) var programAudioSourceID: CameraSourceID?
    var settings: PreviewMonitorSettings = PreviewMonitorPreferencesStore.load() {
        didSet {
            PreviewMonitorPreferencesStore.save(settings)
            clampCurrentPage()
            restartPaginationIfNeeded()
        }
    }
    var currentPage = 0
    var onSelectPreview: ((CameraSourceID) -> Void)?

    private var paginationTask: Task<Void, Never>?

    private init() {}

    func sync(
        sources: [ConnectedCameraSource],
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?,
        programAudioSourceID: CameraSourceID?
    ) {
        cameras = sources.enumerated().map { index, source in
            PreviewMonitorCamera(
                id: source.id,
                displayName: source.displayName,
                track: source.videoTrack,
                isConnected: source.connectionState == .connected,
                isMuted: source.remoteSettings.isMuted,
                sourceIndex: index
            )
        }
        self.previewSourceID = previewSourceID
        self.programSourceID = programSourceID
        self.programAudioSourceID = programAudioSourceID
        clampCurrentPage()
    }

    func bind(onSelect: @escaping (CameraSourceID) -> Void) {
        onSelectPreview = onSelect
        restartPaginationIfNeeded()
    }

    func unbind() {
        onSelectPreview = nil
        stopPagination()
    }

    func selectPreview(_ sourceID: CameraSourceID) {
        onSelectPreview?(sourceID)
    }

    func restartPaginationIfNeeded() {
        stopPagination()
        guard settings.autoPaginate, totalPages > 1 else { return }

        paginationTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(self?.settings.pageIntervalSeconds ?? 6))
                guard !Task.isCancelled, let self else { return }
                currentPage = (currentPage + 1) % totalPages
            }
        }
    }

    func stopPagination() {
        paginationTask?.cancel()
        paginationTask = nil
    }

    var totalPages: Int {
        let spec = PreviewMultiviewLayoutEngine.gridSpec(for: max(1, cameras.count), mode: settings.layoutMode)
        let showHero = settings.layoutMode == .programPlusGrid && settings.overlays.showProgramInGrid
        return PreviewMultiviewLayoutEngine.pageCount(
            cameraCount: cameras.count,
            spec: spec,
            includesProgramHero: showHero
        )
    }

    var previewDisplayName: String? {
        guard let previewSourceID else { return nil }
        return cameras.first { $0.id == previewSourceID }?.displayName
    }

    var programDisplayName: String? {
        guard let programSourceID else { return nil }
        return cameras.first { $0.id == programSourceID }?.displayName
    }

    private func clampCurrentPage() {
        let pages = totalPages
        if currentPage >= pages {
            currentPage = max(0, pages - 1)
        }
    }
}
