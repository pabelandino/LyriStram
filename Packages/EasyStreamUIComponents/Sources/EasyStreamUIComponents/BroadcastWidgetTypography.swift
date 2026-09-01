import SwiftUI
import EasyStreamCore

public enum BroadcastWidgetTypography {
    public static func font(
        _ preset: BroadcastFontPreset,
        size: Double,
        weight: Font.Weight = .regular
    ) -> Font {
        let resolvedSize = max(8, size)
        switch preset {
        case .system:
            return .system(size: resolvedSize, weight: weight)
        case .rounded:
            return .system(size: resolvedSize, weight: weight, design: .rounded)
        case .serif:
            return .system(size: resolvedSize, weight: weight, design: .serif)
        case .monospaced:
            return .system(size: resolvedSize, weight: weight, design: .monospaced)
        case .condensed:
            return .system(size: resolvedSize, weight: weight, design: .default).width(.condensed)
        case .boldDisplay:
            return .system(size: resolvedSize, weight: .bold, design: .rounded)
        }
    }

    public static func measureTextWidth(
        _ text: String,
        preset: BroadcastFontPreset,
        size: Double,
        weight: Font.Weight = .semibold,
        horizontalPadding: CGFloat = 32
    ) -> CGFloat {
        let font = platformFont(preset: preset, size: size, weight: weight)
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        return textWidth + horizontalPadding
    }

#if os(macOS)
    private static func platformFont(preset: BroadcastFontPreset, size: Double, weight: Font.Weight) -> NSFont {
        let resolvedSize = max(8, size)
        let nsWeight: NSFont.Weight = switch weight {
        case .bold: .bold
        case .semibold: .semibold
        case .medium: .medium
        case .light: .light
        default: .regular
        }
        switch preset {
        case .monospaced:
            return NSFont.monospacedSystemFont(ofSize: resolvedSize, weight: nsWeight)
        case .serif:
            return NSFont(name: "Times New Roman", size: resolvedSize) ?? NSFont.systemFont(ofSize: resolvedSize, weight: nsWeight)
        default:
            return NSFont.systemFont(ofSize: resolvedSize, weight: nsWeight)
        }
    }
#else
    private static func platformFont(preset: BroadcastFontPreset, size: Double, weight: Font.Weight) -> UIFont {
        let resolvedSize = max(8, size)
        let uiWeight: UIFont.Weight = switch weight {
        case .bold: .bold
        case .semibold: .semibold
        case .medium: .medium
        case .light: .light
        default: .regular
        }
        switch preset {
        case .monospaced:
            return UIFont.monospacedSystemFont(ofSize: resolvedSize, weight: uiWeight)
        case .serif:
            return UIFont(name: "Times New Roman", size: resolvedSize) ?? UIFont.systemFont(ofSize: resolvedSize, weight: uiWeight)
        default:
            return UIFont.systemFont(ofSize: resolvedSize, weight: uiWeight)
        }
    }
#endif
}

public enum BroadcastWidgetColors {
    public static func color(hex: String?, fallback: Color = .white) -> Color {
        guard let hex, !hex.isEmpty, let color = Color(widgetHex: hex) else { return fallback }
        return color
    }

    public static func binding(for hex: Binding<String?>, fallback: String) -> Binding<Color> {
        Binding(
            get: { color(hex: hex.wrappedValue ?? fallback) },
            set: { hex.wrappedValue = $0.widgetHexString(includeAlpha: true) }
        )
    }

    public static func binding(for hex: Binding<String>, fallback: String) -> Binding<Color> {
        Binding(
            get: { color(hex: hex.wrappedValue.isEmpty ? fallback : hex.wrappedValue) },
            set: { hex.wrappedValue = $0.widgetHexString(includeAlpha: true) }
        )
    }

    public static func gradient(_ style: BroadcastGradientStyle) -> LinearGradient {
        LinearGradient(
            colors: [
                color(hex: style.startColorHex),
                color(hex: style.endColorHex),
            ],
            startPoint: gradientStartPoint(angleDegrees: style.angleDegrees),
            endPoint: gradientEndPoint(angleDegrees: style.angleDegrees)
        )
    }

    private static func gradientStartPoint(angleDegrees: Double) -> UnitPoint {
        let radians = angleDegrees * .pi / 180
        return UnitPoint(x: 0.5 - cos(radians) * 0.5, y: 0.5 - sin(radians) * 0.5)
    }

    private static func gradientEndPoint(angleDegrees: Double) -> UnitPoint {
        let radians = angleDegrees * .pi / 180
        return UnitPoint(x: 0.5 + cos(radians) * 0.5, y: 0.5 + sin(radians) * 0.5)
    }
}

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension Color {
    init?(widgetHex hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") { sanitized.removeFirst() }

        if sanitized.count == 8 {
            guard let value = UInt64(sanitized, radix: 16) else { return nil }
            let alpha = Double((value >> 24) & 0xFF) / 255
            let red = Double((value >> 16) & 0xFF) / 255
            let green = Double((value >> 8) & 0xFF) / 255
            let blue = Double(value & 0xFF) / 255
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
            return
        }

        guard sanitized.count == 6, let value = UInt64(sanitized, radix: 16) else { return nil }
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }

    func widgetHexString(includeAlpha: Bool = false) -> String {
#if os(macOS)
        let nsColor = NSColor(self)
        guard let rgb = nsColor.usingColorSpace(.sRGB) else { return "FFFFFF" }
        let red = Int(round(rgb.redComponent * 255))
        let green = Int(round(rgb.greenComponent * 255))
        let blue = Int(round(rgb.blueComponent * 255))
        if includeAlpha {
            let alpha = Int(round(rgb.alphaComponent * 255))
            return String(format: "%02X%02X%02X%02X", alpha, red, green, blue)
        }
        return String(format: "%02X%02X%02X", red, green, blue)
#else
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        if includeAlpha {
            return String(
                format: "%02X%02X%02X%02X",
                Int(round(alpha * 255)),
                Int(round(red * 255)),
                Int(round(green * 255)),
                Int(round(blue * 255))
            )
        }
        return String(
            format: "%02X%02X%02X",
            Int(round(red * 255)),
            Int(round(green * 255)),
            Int(round(blue * 255))
        )
#endif
    }
}

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

/// Loads widget logos asynchronously; image is held in @State so TimelineView ticks do not hit disk.
public struct CachedWidgetLogoView: View {
    let logoURL: URL?
    private let contentBuilder: (Image) -> AnyView
    private let placeholderBuilder: () -> AnyView

    @State private var loadedImage: Image?

    public init<Content: View, Placeholder: View>(
        logoURL: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.logoURL = logoURL
        self.contentBuilder = { AnyView(content($0)) }
        self.placeholderBuilder = { AnyView(placeholder()) }
    }

    public var body: some View {
        Group {
            if let loadedImage {
                contentBuilder(loadedImage)
            } else {
                placeholderBuilder()
            }
        }
        .task(id: logoURL) {
            guard let logoURL else {
                loadedImage = nil
                return
            }
            if let cached = BroadcastWidgetImageLoader.load(url: logoURL) {
                loadedImage = cached
                return
            }
            let url = logoURL
            loadedImage = await Task.detached(priority: .utility) {
                BroadcastWidgetImageLoader.loadAndCache(url: url)
            }.value
        }
    }
}
