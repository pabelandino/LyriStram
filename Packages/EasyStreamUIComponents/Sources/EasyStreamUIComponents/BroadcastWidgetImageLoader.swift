import SwiftUI

#if os(macOS)
import AppKit

public enum BroadcastWidgetImageLoader {
    private nonisolated(unsafe) static let cache = NSCache<NSURL, NSImage>()

    public static func load(url: URL?) -> Image? {
        guard let url else { return nil }
        if let cached = cache.object(forKey: url as NSURL) {
            return Image(nsImage: cached)
        }
        guard let loaded = NSImage(contentsOf: url) else { return nil }
        cache.setObject(loaded, forKey: url as NSURL)
        return Image(nsImage: loaded)
    }

    public static func loadAndCache(url: URL) -> Image? {
        load(url: url)
    }

    public static func aspectRatio(for url: URL?) -> CGFloat? {
        guard let url else { return nil }
        if let cached = cache.object(forKey: url as NSURL) {
            return cached.size.width / max(cached.size.height, 1)
        }
        guard let loaded = NSImage(contentsOf: url), loaded.size.height > 0 else { return nil }
        cache.setObject(loaded, forKey: url as NSURL)
        return loaded.size.width / loaded.size.height
    }
}
#else
import UIKit

public enum BroadcastWidgetImageLoader {
    private nonisolated(unsafe) static let cache = NSCache<NSURL, UIImage>()

    public static func load(url: URL?) -> Image? {
        guard let url else { return nil }
        if let cached = cache.object(forKey: url as NSURL) {
            return Image(uiImage: cached)
        }
        guard let loaded = UIImage(contentsOfFile: url.path) else { return nil }
        cache.setObject(loaded, forKey: url as NSURL)
        return Image(uiImage: loaded)
    }

    public static func loadAndCache(url: URL) -> Image? {
        load(url: url)
    }

    public static func aspectRatio(for url: URL?) -> CGFloat? {
        guard let url else { return nil }
        if let cached = cache.object(forKey: url as NSURL) {
            return cached.size.width / max(cached.size.height, 1)
        }
        guard let loaded = UIImage(contentsOfFile: url.path), loaded.size.height > 0 else { return nil }
        cache.setObject(loaded, forKey: url as NSURL)
        return loaded.size.width / loaded.size.height
    }
}
#endif
