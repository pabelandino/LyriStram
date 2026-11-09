import Foundation
import SwiftUI
import ImageIO
import AVFoundation
import EasyStreamCore
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Downsampled media library thumbnails — avoids decoding full-resolution images on the main thread.
public enum BroadcastMediaThumbnailLoader {
    private nonisolated(unsafe) static let cache = NSCache<NSString, ThumbnailBox>()
    private static let maxPixelSize: CGFloat = 128

    public static func cachedImage(for url: URL, video: Bool = false) -> Image? {
        cache.object(forKey: cacheKey(for: url, maxPixelSize: maxPixelSize, video: video) as NSString)?.image
    }

    public static func loadThumbnail(from url: URL) async -> Image? {
        await loadImage(from: url, maxPixelSize: maxPixelSize)
    }

    public static func loadVideoThumbnail(from url: URL) async -> Image? {
        let key = cacheKey(for: url, maxPixelSize: maxPixelSize, video: true) as NSString
        if let boxed = cache.object(forKey: key) {
            return boxed.image
        }

        let image: Image? = await Task.detached(priority: .utility) {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: maxPixelSize, height: maxPixelSize)
            let time = CMTime(seconds: 0.1, preferredTimescale: 600)
            guard let cgImage = try? await generator.image(at: time).image else {
                return nil as Image?
            }
            #if os(macOS)
            return Image(nsImage: NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height)))
            #else
            return Image(uiImage: UIImage(cgImage: cgImage))
            #endif
        }.value

        if let image {
            cache.setObject(ThumbnailBox(image: image), forKey: key)
        }
        return image
    }

    private static func cacheKey(for url: URL, maxPixelSize: CGFloat, video: Bool) -> String {
        let kind = video ? "video" : "image"
        return "\(url.path)|\(kind)|\(Int(maxPixelSize))"
    }

    /// Program-preview image decode (downsampled, off main thread).
    public static func loadPreviewImage(from url: URL, maxPixelSize: CGFloat = 1600) async -> Image? {
        await loadImage(from: url, maxPixelSize: maxPixelSize)
    }

    private static func loadImage(from url: URL, maxPixelSize: CGFloat) async -> Image? {
        let key = cacheKey(for: url, maxPixelSize: maxPixelSize, video: false) as NSString
        if let boxed = cache.object(forKey: key) {
            return boxed.image
        }

        let image: Image? = await Task.detached(priority: .utility) {
            guard let platformImage = decodeThumbnail(at: url, maxPixelSize: maxPixelSize) else {
                return nil as Image?
            }
            #if os(macOS)
            return Image(nsImage: platformImage)
            #else
            return Image(uiImage: platformImage)
            #endif
        }.value

        if let image {
            cache.setObject(ThumbnailBox(image: image), forKey: key)
        }
        return image
    }

    #if os(macOS)
    private static func decodeThumbnail(at url: URL, maxPixelSize: CGFloat) -> NSImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return NSImage(
            cgImage: cgImage,
            size: NSSize(width: cgImage.width, height: cgImage.height)
        )
    }
    #else
    private static func decodeThumbnail(at url: URL, maxPixelSize: CGFloat) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    #endif

    private final class ThumbnailBox: NSObject {
        let image: Image
        init(image: Image) { self.image = image }
    }
}

/// Defers heavy library list construction by one run-loop turn so live video keeps priority.
public struct DeferredBroadcastLibraryPanel: View {
    @Binding var selectedKind: BroadcastResourceKind
    let imageResources: [BroadcastResource]
    let videoResources: [BroadcastResource]
    let widgetResources: [BroadcastResource]
    let activeResourceIDs: Set<UUID>
    let lyrioraResourceIDs: Set<UUID>
    let editingResourceID: UUID?
    let searchText: String
    let onSearchChange: (String) -> Void
    let onImport: (BroadcastResourceKind) -> Void
    let onCreateWidget: () -> Void
    let onEditWidget: (BroadcastResource) -> Void
    let onSelectResource: (BroadcastResource) -> Void
    let onTakeToProgram: (BroadcastResource) -> Void
    let onRemoveFromProgram: (BroadcastResource) -> Void
    let fileURL: (BroadcastResource) -> URL

    @State private var isPanelReady = false

    public init(
        selectedKind: Binding<BroadcastResourceKind>,
        imageResources: [BroadcastResource],
        videoResources: [BroadcastResource],
        widgetResources: [BroadcastResource],
        activeResourceIDs: Set<UUID>,
        lyrioraResourceIDs: Set<UUID> = [],
        editingResourceID: UUID?,
        searchText: String,
        onSearchChange: @escaping (String) -> Void,
        onImport: @escaping (BroadcastResourceKind) -> Void,
        onCreateWidget: @escaping () -> Void,
        onEditWidget: @escaping (BroadcastResource) -> Void,
        onSelectResource: @escaping (BroadcastResource) -> Void,
        onTakeToProgram: @escaping (BroadcastResource) -> Void,
        onRemoveFromProgram: @escaping (BroadcastResource) -> Void,
        fileURL: @escaping (BroadcastResource) -> URL
    ) {
        self._selectedKind = selectedKind
        self.imageResources = imageResources
        self.videoResources = videoResources
        self.widgetResources = widgetResources
        self.activeResourceIDs = activeResourceIDs
        self.lyrioraResourceIDs = lyrioraResourceIDs
        self.editingResourceID = editingResourceID
        self.searchText = searchText
        self.onSearchChange = onSearchChange
        self.onImport = onImport
        self.onCreateWidget = onCreateWidget
        self.onEditWidget = onEditWidget
        self.onSelectResource = onSelectResource
        self.onTakeToProgram = onTakeToProgram
        self.onRemoveFromProgram = onRemoveFromProgram
        self.fileURL = fileURL
    }

    public var body: some View {
        ZStack {
            if isPanelReady {
                BroadcastMediaLibraryPanel(
                    selectedKind: $selectedKind,
                    imageResources: imageResources,
                    videoResources: videoResources,
                    widgetResources: widgetResources,
                    activeResourceIDs: activeResourceIDs,
                    lyrioraResourceIDs: lyrioraResourceIDs,
                    editingResourceID: editingResourceID,
                    searchText: searchText,
                    onSearchChange: onSearchChange,
                    onImport: onImport,
                    onCreateWidget: onCreateWidget,
                    onEditWidget: onEditWidget,
                    onSelectResource: onSelectResource,
                    onTakeToProgram: onTakeToProgram,
                    onRemoveFromProgram: onRemoveFromProgram,
                    fileURL: fileURL
                )
                .transition(.opacity)
            } else {
                VStack(spacing: 10) {
                    ProgressView()
                    Text("Cargando biblioteca…")
                        .font(.caption)
                        .foregroundStyle(BroadcastTheme.subtleText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        }
        .animation(.easeOut(duration: 0.15), value: isPanelReady)
        .task {
            guard !isPanelReady else { return }
            await Task.yield()
            isPanelReady = true
        }
    }
}
