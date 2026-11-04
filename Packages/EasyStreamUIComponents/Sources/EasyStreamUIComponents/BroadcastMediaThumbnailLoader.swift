import Foundation
import SwiftUI
import ImageIO
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

    public static func cachedImage(for url: URL) -> Image? {
        let key = url.path as NSString
        if let boxed = cache.object(forKey: key) {
            return boxed.image
        }
        return nil
    }

    public static func loadThumbnail(from url: URL) async -> Image? {
        await loadImage(from: url, maxPixelSize: maxPixelSize)
    }

    /// Program-preview image decode (downsampled, off main thread).
    public static func loadPreviewImage(from url: URL, maxPixelSize: CGFloat = 1600) async -> Image? {
        await loadImage(from: url, maxPixelSize: maxPixelSize)
    }

    private static func loadImage(from url: URL, maxPixelSize: CGFloat) async -> Image? {
        let key = "\(url.path)|\(Int(maxPixelSize))" as NSString
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
    let resources: [BroadcastResource]
    let activeResourceIDs: Set<UUID>
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

    private var loadToken: String {
        "\(selectedKind.rawValue)|\(resources.count)|\(searchText)"
    }

    public init(
        selectedKind: Binding<BroadcastResourceKind>,
        resources: [BroadcastResource],
        activeResourceIDs: Set<UUID>,
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
        self.resources = resources
        self.activeResourceIDs = activeResourceIDs
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
                    resources: resources,
                    activeResourceIDs: activeResourceIDs,
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
        .task(id: loadToken) {
            isPanelReady = false
            await Task.yield()
            isPanelReady = true
        }
    }
}
