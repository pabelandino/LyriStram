import SwiftUI
import EasyStreamCore
#if os(macOS)
import AppKit
#endif

/// Hex-backed color control. macOS opens the system color panel from a swatch button; iOS uses SwiftUI `ColorPicker`.
public struct BroadcastHexColorWell: View {
    private let hexBinding: Binding<String>
    let supportsOpacity: Bool
    let fallback: String

    public init(hex: Binding<String>, supportsOpacity: Bool = false, fallback: String = "FFFFFF") {
        hexBinding = hex
        self.supportsOpacity = supportsOpacity
        self.fallback = fallback
    }

    public init(optionalHex: Binding<String?>, supportsOpacity: Bool = false, fallback: String = "FFFFFF") {
        hexBinding = Binding(
            get: { optionalHex.wrappedValue ?? fallback },
            set: { optionalHex.wrappedValue = $0 }
        )
        self.supportsOpacity = supportsOpacity
        self.fallback = fallback
    }

    public var body: some View {
#if os(macOS)
        NativeMacColorPanelButton(
            hex: hexBinding,
            supportsOpacity: supportsOpacity,
            fallback: fallback
        )
        .frame(width: 48, height: 28)
#else
        iosColorPicker
#endif
    }

#if os(iOS)
    @State private var pickerColor: Color = .white

    private var iosColorPicker: some View {
        ColorPicker(
            "",
            selection: Binding(
                get: { pickerColor },
                set: { applyPickerColor($0) }
            ),
            supportsOpacity: supportsOpacity
        )
        .labelsHidden()
        .onAppear { syncPickerColorFromHex() }
        .onChange(of: hexBinding.wrappedValue) { _, _ in
            syncPickerColorFromHex()
        }
    }

    private var currentColor: Color {
        BroadcastWidgetColors.color(
            hex: hexBinding.wrappedValue.isEmpty ? fallback : hexBinding.wrappedValue,
            fallback: Color(widgetHex: fallback) ?? .white
        )
    }

    private func syncPickerColorFromHex() {
        pickerColor = currentColor
    }

    private func applyPickerColor(_ color: Color) {
        pickerColor = color
        hexBinding.wrappedValue = color.widgetHexString(includeAlpha: supportsOpacity)
    }
#endif
}

#if os(macOS)
/// Swatch button that opens a centered system color panel (avoids embedded `NSColorWell` focus artifacts).
private struct NativeMacColorPanelButton: View {
    @Binding var hex: String
    let supportsOpacity: Bool
    let fallback: String

    private var displayColor: Color {
        let raw = hex.isEmpty ? fallback : hex
        return Color(widgetHex: raw) ?? .white
    }

    var body: some View {
        Button {
            MacColorPanelController.shared.present(
                hex: $hex,
                supportsOpacity: supportsOpacity,
                fallback: fallback
            )
        } label: {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(displayColor)
                .overlay {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.22), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .help("Elegir color")
    }
}

@MainActor
private final class MacColorPanelController: NSObject {
    static let shared = MacColorPanelController()

    private var hexBinding: Binding<String>?
    private var supportsOpacity = false
    private var fallback = "FFFFFF"

    private override init() {
        super.init()
    }

    func present(hex: Binding<String>, supportsOpacity: Bool, fallback: String) {
        hexBinding = hex
        self.supportsOpacity = supportsOpacity
        self.fallback = fallback

        let panel = NSColorPanel.shared
        panel.setTarget(self)
        panel.setAction(#selector(panelColorChanged(_:)))
        panel.isContinuous = true
        panel.showsAlpha = supportsOpacity
        panel.color = nsColor(for: hex.wrappedValue)

        center(panel)
        panel.orderFrontRegardless()
    }

    @objc private func panelColorChanged(_ sender: NSColorPanel) {
        guard let hexBinding else { return }
        let swiftColor = Color(nsColor: sender.color.usingColorSpace(.sRGB) ?? sender.color)
        hexBinding.wrappedValue = swiftColor.widgetHexString(includeAlpha: supportsOpacity)
    }

    private func center(_ panel: NSPanel) {
        guard let screen = NSApp.keyWindow?.screen ?? NSScreen.main ?? NSScreen.screens.first else { return }
        let visible = screen.visibleFrame
        var frame = panel.frame
        frame.origin.x = visible.midX - frame.width * 0.5
        frame.origin.y = visible.midY - frame.height * 0.5
        panel.setFrame(frame, display: true)
    }

    private func nsColor(for hexValue: String) -> NSColor {
        let raw = hexValue.isEmpty ? fallback : hexValue
        if let swift = Color(widgetHex: raw) {
            return NSColor(swift).usingColorSpace(.sRGB) ?? .white
        }
        return .white
    }
}
#endif
