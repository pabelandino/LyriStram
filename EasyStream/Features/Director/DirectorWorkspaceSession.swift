import Foundation
import Observation
import EasyStreamTransport

/// Active director session handle for auxiliary windows (settings, quality, stream).
@MainActor
@Observable
final class DirectorWorkspaceSession {
    static let shared = DirectorWorkspaceSession()

    private(set) var sessionViewModel: DirectorSessionViewModel?
    private(set) var mediaViewModel: BroadcastMediaViewModel?
    private(set) var intercomService: TeamIntercomService?
    private(set) var previewMonitor: DirectorPreviewMonitorStore?
    var onOpenPreviewMonitor: (() -> Void)?
    var onConfigurePreviewMonitor: (() -> Void)?

    private init() {}

    func bind(
        viewModel: DirectorSessionViewModel,
        mediaViewModel: BroadcastMediaViewModel,
        intercomService: TeamIntercomService,
        previewMonitor: DirectorPreviewMonitorStore,
        onOpenPreviewMonitor: @escaping () -> Void,
        onConfigurePreviewMonitor: @escaping () -> Void
    ) {
        sessionViewModel = viewModel
        self.mediaViewModel = mediaViewModel
        self.intercomService = intercomService
        self.previewMonitor = previewMonitor
        self.onOpenPreviewMonitor = onOpenPreviewMonitor
        self.onConfigurePreviewMonitor = onConfigurePreviewMonitor
    }

    func unbind() {
        sessionViewModel = nil
        mediaViewModel = nil
        intercomService = nil
        previewMonitor = nil
        onOpenPreviewMonitor = nil
        onConfigurePreviewMonitor = nil
    }
}
