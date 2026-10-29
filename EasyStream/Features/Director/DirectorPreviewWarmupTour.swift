import Foundation
import EasyStreamCore

/// Once per director session, briefly selects each connected camera so idle tiles receive JPEG snapshots.
@MainActor
enum DirectorPreviewWarmupTour {
    private static var tourTask: Task<Void, Never>?
    private static var hasCompleted = false

    static func reset() {
        tourTask?.cancel()
        tourTask = nil
        hasCompleted = false
    }

    static func scheduleIfNeeded(
        sources: [ConnectedCameraSource],
        programSourceID: CameraSourceID?,
        previewSourceID: CameraSourceID?,
        idleSnapshotsEnabled: Bool,
        selectPreview: @escaping (CameraSourceID) -> Void
    ) {
        guard !hasCompleted else { return }
        guard idleSnapshotsEnabled else { return }

        let connected = sources.filter { $0.connectionState == .connected && $0.videoTrack != nil }
        guard connected.count >= 2 else { return }

        tourTask?.cancel()
        tourTask = Task {
            try? await Task.sleep(for: .seconds(1.8))
            guard !Task.isCancelled, !hasCompleted else { return }

            let tourTargets = connected.filter { $0.id != programSourceID }
            guard tourTargets.count >= 2 else {
                hasCompleted = true
                return
            }

            let restoreID = previewSourceID ?? tourTargets.first?.id

            for source in tourTargets {
                guard !Task.isCancelled else { return }
                selectPreview(source.id)
                try? await Task.sleep(for: .milliseconds(1_400))
            }

            if let restoreID, restoreID != programSourceID {
                selectPreview(restoreID)
            }

            hasCompleted = true
        }
    }
}
