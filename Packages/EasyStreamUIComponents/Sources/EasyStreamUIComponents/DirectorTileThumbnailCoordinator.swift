import CoreImage
import CoreVideo
import EasyStreamCore
import EasyStreamVideoPipeline
import Observation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import WebRTC

private enum DirectorThumbnailImageConversion {
    static let ciContext = CIContext(options: [.cacheIntermediates: false])
}

/// SwiftUI-facing store — observes thumbnail bus updates per camera source.
@MainActor
@Observable
public final class DirectorSourceThumbnailStore {
    public static let shared = DirectorSourceThumbnailStore()

    static let didUpdateNotification = Notification.Name("DirectorSourceThumbnailStore.didUpdate")
    static let sourceIDUserInfoKey = "sourceID"

    private(set) var revisions: [CameraSourceID: UInt64] = [:]
    private var imageCache: [CameraSourceID: (sequence: UInt64, image: Image)] = [:]
    private var conversionTasks: [CameraSourceID: Task<Void, Never>] = [:]

    private init() {
        DirectorSourceThumbnailBus.shared.onThumbnailUpdated = { [weak self] sourceID in
            Task { @MainActor in
                self?.scheduleConversion(for: sourceID)
            }
        }
    }

    public func thumbnailImage(for sourceID: CameraSourceID) -> Image? {
        guard let snapshot = DirectorSourceThumbnailBus.shared.snapshot(for: sourceID) else {
            return nil
        }
        if let cached = imageCache[sourceID], cached.sequence == snapshot.sequence {
            return cached.image
        }
        scheduleConversion(for: sourceID)
        return imageCache[sourceID]?.image
    }

    private func scheduleConversion(for sourceID: CameraSourceID) {
        guard let snapshot = DirectorSourceThumbnailBus.shared.snapshot(for: sourceID) else {
            imageCache.removeValue(forKey: sourceID)
            revisions.removeValue(forKey: sourceID)
            conversionTasks[sourceID]?.cancel()
            conversionTasks.removeValue(forKey: sourceID)
            return
        }
        if let cached = imageCache[sourceID], cached.sequence == snapshot.sequence {
            return
        }
        conversionTasks[sourceID]?.cancel()
        let sequence = snapshot.sequence
        let jpegData = snapshot.jpegData
        let pixelBuffer = snapshot.pixelBuffer
        conversionTasks[sourceID] = Task.detached(priority: .utility) { [sourceID, sequence, jpegData, pixelBuffer] in
            let cgImage: CGImage?
            if let pixelBuffer {
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                cgImage = DirectorThumbnailImageConversion.ciContext.createCGImage(ciImage, from: ciImage.extent)
            } else if let jpegData {
                cgImage = DirectorThumbnailJPEGDecoder.decode(jpegData)
            } else {
                cgImage = nil
            }
            guard let cgImage else {
                TileThumbnailTrace.eventThrottled(
                    "jpeg-decode-fail-\(sourceID.rawValue.uuidString.prefix(8))",
                    intervalMs: 5_000,
                    "director jpeg decode failed source=\(ProgramBusTrace.shortSourceID(sourceID.rawValue)) bytes=\(jpegData?.count ?? 0)"
                )
                return
            }
            let image = Image(decorative: cgImage, scale: 1, orientation: .up)
            await MainActor.run {
                guard !Task.isCancelled else { return }
                guard DirectorSourceThumbnailBus.shared.snapshot(for: sourceID)?.sequence == sequence else {
                    return
                }
                Self.shared.imageCache[sourceID] = (sequence, image)
                Self.shared.revisions[sourceID] = sequence
                NotificationCenter.default.post(
                    name: Self.didUpdateNotification,
                    object: nil,
                    userInfo: [Self.sourceIDUserInfoKey: sourceID]
                )
            }
        }
    }
}

/// Attaches throttled thumbnail sinks to idle tile sources on the director.
@MainActor
public enum DirectorTileThumbnailCoordinator {
    private static var sinks: [CameraSourceID: BroadcastTileThumbnailSink] = [:]
    private static var attachedTracks: [CameraSourceID: RTCVideoTrack] = [:]

    public static func sync(
        sources: [CameraSourceID: RTCVideoTrack?],
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?,
        idleThumbnailsEnabled: Bool
    ) {
        guard idleThumbnailsEnabled else {
            if !sinks.isEmpty {
                TileThumbnailTrace.event("director thumbnails disabled (pauseIdle) detaching=\(sinks.count)")
            }
            reset()
            return
        }

        var needed = Set<CameraSourceID>()
        for (sourceID, track) in sources {
            guard track != nil else { continue }
            guard DirectorPreviewTileTrackPolicy.shouldAttachTileThumbnail(
                for: sourceID,
                previewSourceID: previewSourceID,
                programSourceID: programSourceID
            ) else {
                continue
            }
            needed.insert(sourceID)
        }

        for sourceID in Set(sinks.keys).subtracting(needed) {
            detach(sourceID: sourceID, reason: "role-changed")
        }

        for sourceID in needed {
            guard let track = sources[sourceID] ?? nil else { continue }
            attach(sourceID: sourceID, track: track)
        }

        TileThumbnailTrace.eventThrottled(
            "sync",
            intervalMs: 1_200,
            "director thumbnail sync attached=\(sinks.count) candidates=\(needed.count)"
        )
    }

    public static func isThumbnailAttached(_ sourceID: CameraSourceID) -> Bool {
        sinks[sourceID] != nil
    }

    public static func reset() {
        for sourceID in sinks.keys {
            detach(sourceID: sourceID, reason: "reset")
        }
        DirectorSourceThumbnailBus.shared.removeAll()
    }

    private static func attach(sourceID: CameraSourceID, track: RTCVideoTrack) {
        if attachedTracks[sourceID] === track, sinks[sourceID] != nil { return }
        detach(sourceID: sourceID, reason: "reattach")
        let sink = BroadcastTileThumbnailSink(sourceID: sourceID)
        track.add(sink)
        sinks[sourceID] = sink
        attachedTracks[sourceID] = track
        VideoRendererSinkRegistry.register(.tileThumbnail)
        TileThumbnailTrace.event(
            "attach source=\(ProgramBusTrace.shortSourceID(sourceID.rawValue)) track=\(ProgramBusTrace.shortTrackId(track.trackId))"
        )
    }

    private static func detach(sourceID: CameraSourceID, reason: String) {
        if let sink = sinks.removeValue(forKey: sourceID),
           let track = attachedTracks.removeValue(forKey: sourceID) {
            track.remove(sink)
            VideoRendererSinkRegistry.unregister(.tileThumbnail)
            TileThumbnailTrace.event(
                "detach source=\(ProgramBusTrace.shortSourceID(sourceID.rawValue)) reason=\(reason)"
            )
        }
        // Keep the last published frame on the bus for idle tile display.
    }
}

/// Still frame for idle switcher tiles (Phase 2 bus thumbnails).
public struct DirectorTileThumbnailView: View {
    let sourceID: CameraSourceID
    @State private var displayImage: Image?

    public init(sourceID: CameraSourceID) {
        self.sourceID = sourceID
    }

    public static func hasThumbnail(for sourceID: CameraSourceID) -> Bool {
        DirectorSourceThumbnailBus.shared.snapshot(for: sourceID) != nil
    }

    public var body: some View {
        Group {
            if let displayImage {
                displayImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.black.opacity(0.85)
            }
        }
        .onAppear { reloadThumbnail() }
        .onReceive(NotificationCenter.default.publisher(for: DirectorSourceThumbnailStore.didUpdateNotification)) { notification in
            guard let updatedID = notification.userInfo?[DirectorSourceThumbnailStore.sourceIDUserInfoKey] as? CameraSourceID,
                  updatedID == sourceID else {
                return
            }
            reloadThumbnail()
        }
    }

    private func reloadThumbnail() {
        displayImage = DirectorSourceThumbnailStore.shared.thumbnailImage(for: sourceID)
    }
}
