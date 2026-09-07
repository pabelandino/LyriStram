import SwiftUI

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
