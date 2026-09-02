import SwiftUI

/// Liquid Glass styling aligned with [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass).
public enum BroadcastGlassStyles {
    public static let cardCornerRadius: CGFloat = 12
    public static let buttonCornerRadius: CGFloat = 10
    public static let controlCornerRadius: CGFloat = 8
}

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

    func broadcastGlassPanel(cornerRadius: CGFloat = BroadcastGlassStyles.cardCornerRadius) -> some View {
        modifier(BroadcastGlassPanelModifier(cornerRadius: cornerRadius))
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

// MARK: - Panels

public struct BroadcastGlassPanelModifier: ViewModifier {
    let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = BroadcastGlassStyles.cardCornerRadius) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        if #available(macOS 26.0, iOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
                .shadow(color: .black.opacity(0.28), radius: 10, y: 5)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(BroadcastTheme.glassHighlight, lineWidth: 0.75)
                }
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .shadow(color: .black.opacity(0.28), radius: 10, y: 5)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(BroadcastTheme.glassHighlight, lineWidth: 0.75)
                }
        }
    }
}

// MARK: - Buttons

public struct BroadcastGlowButtonStyle: ButtonStyle {
    let tint: Color
    let isProminent: Bool

    public init(tint: Color, isProminent: Bool = true) {
        self.tint = tint
        self.isProminent = isProminent
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .foregroundStyle(isProminent ? Color.white : tint)
            .background {
                if isProminent {
                    RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.95), tint.opacity(0.72)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: tint.opacity(configuration.isPressed ? 0.15 : 0.45), radius: 12, y: 4)
                } else if #available(macOS 26.0, iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                        .fill(.clear)
                        .glassEffect(.regular, in: .rect(cornerRadius: BroadcastGlassStyles.buttonCornerRadius))
                        .overlay {
                            RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                                .strokeBorder(tint.opacity(0.35), lineWidth: 1)
                        }
                } else {
                    RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                                .strokeBorder(tint.opacity(0.35), lineWidth: 1)
                        }
                }
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Prominent take-to-program control with hover + pressed feedback (macOS and iOS).
public struct BroadcastTakeButtonStyle: ButtonStyle {
    let isHovered: Bool
    let isPressing: Bool
    private let tint = BroadcastTheme.programRed

    public init(isHovered: Bool = false, isPressing: Bool = false) {
        self.isHovered = isHovered
        self.isPressing = isPressing
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || isPressing
        let isHighlighted = isHovered && !isPressed

        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.white.opacity(isPressed ? 0.88 : 1))
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                        .fill(buttonGradient(isPressed: isPressed, isHighlighted: isHighlighted))

                    RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                        .strokeBorder(
                            Color.white.opacity(isPressed ? 0.1 : (isHighlighted ? 0.34 : 0.22)),
                            lineWidth: isHighlighted ? 1.5 : 1
                        )

                    if !isPressed {
                        RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(isHighlighted ? 0.2 : 0.12), lineWidth: 1)
                            .blur(radius: 0.5)
                            .offset(y: -0.5)
                            .mask {
                                RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [.white, .clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )
                            }
                    }
                }
                .shadow(
                    color: tint.opacity(isPressed ? 0.1 : (isHighlighted ? 0.55 : 0.42)),
                    radius: isPressed ? 2 : (isHighlighted ? 14 : 10),
                    y: isPressed ? 1 : (isHighlighted ? 6 : 5)
                )
            }
            .overlay {
                RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                    .fill(Color.black.opacity(isPressed ? 0.32 : (isHighlighted ? 0.06 : 0)))
            }
            .scaleEffect(isPressed ? 0.95 : (isHighlighted ? 1.02 : 1), anchor: .center)
            .offset(y: isPressed ? 3 : 0)
            .brightness(isHighlighted ? 0.06 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.68), value: isPressed)
            .animation(.easeOut(duration: 0.14), value: isHighlighted)
    }

    private func buttonGradient(isPressed: Bool, isHighlighted: Bool) -> LinearGradient {
        LinearGradient(
            colors: [
                tint.opacity(isPressed ? 0.62 : (isHighlighted ? 1 : 0.95)),
                tint.opacity(isPressed ? 0.48 : (isHighlighted ? 0.82 : 0.72))
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

public struct BroadcastGlassProminentButtonStyle: ButtonStyle {
    let tint: Color

    public init(tint: Color = BroadcastTheme.controlAccent) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        BroadcastGlowButtonStyle(tint: tint, isProminent: true)
            .makeBody(configuration: configuration)
    }
}

public struct BroadcastGlassBorderedButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        BroadcastGlowButtonStyle(tint: BroadcastTheme.controlAccent, isProminent: false)
            .makeBody(configuration: configuration)
    }
}
