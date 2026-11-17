import SwiftUI

// MARK: - App chrome

public struct BroadcastStudioChromeModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .tint(BroadcastTheme.controlAccent)
            .preferredColorScheme(.dark)
    }
}

public extension View {
    /// Global studio tint for native toggles, segmented pickers, sliders, and menus.
    func broadcastStudioChrome() -> some View {
        modifier(BroadcastStudioChromeModifier())
    }

    /// Full-screen and auxiliary windows — always dark studio chrome regardless of macOS appearance.
    func broadcastStudioWindowStyle() -> some View {
        self
            .broadcastStudioChrome()
            .background(BroadcastTheme.panelBackground)
#if os(macOS)
            .background(BroadcastWindowAppearanceConfigurator())
#endif
    }

    /// Glass backing for grouped custom controls (not native segmented pickers).
    func broadcastGlassControlChrome(
        cornerRadius: CGFloat = BroadcastGlassStyles.controlCornerRadius
    ) -> some View {
        padding(3)
            .background {
                if #available(macOS 26.0, iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.clear)
                        .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            }
    }

    /// Native segmented control — system Liquid Glass on macOS 26; tint comes from `broadcastStudioChrome()`.
    func broadcastNativeSegmentedControl() -> some View {
        labelsHidden()
            .controlSize(.regular)
            .pickerStyle(.segmented)
    }

#if os(macOS)
    @ViewBuilder
    func broadcastBarlessWindow() -> some View {
        background(BroadcastBarlessWindowConfigurator())
    }

    func broadcastHiddenWindowToolbar() -> some View {
        modifier(BroadcastHiddenToolbarModifier())
    }

    /// Keeps content below the traffic-light safe area in barless windows.
    func broadcastTitlebarSafeArea() -> some View {
        safeAreaPadding(.top, 10)
    }
#else
    func broadcastBarlessWindow() -> some View { self }
    func broadcastHiddenWindowToolbar() -> some View { self }
    func broadcastTitlebarSafeArea() -> some View { self }
#endif
}

#if os(macOS)
private struct BroadcastHiddenToolbarModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 15.0, *) {
            content
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .toolbarBackgroundVisibility(.hidden, for: .automatic)
        } else {
            content
        }
    }
}
#endif
