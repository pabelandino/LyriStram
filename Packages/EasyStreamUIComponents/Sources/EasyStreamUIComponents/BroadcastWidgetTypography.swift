import SwiftUI
import EasyStreamCore

#if os(macOS)
import AppKit
#else
import UIKit
#endif

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
