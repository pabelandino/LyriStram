import SwiftUI
import EasyStreamCore

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
