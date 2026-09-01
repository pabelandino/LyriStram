import SwiftUI
import EasyStreamCore
#if os(macOS)
import AppKit
#endif

public enum WidgetOverlayContentSizing: Sendable {
    case fillFrame
    /// Logos use a square frame so handles hug the visible logo bounds.
    case uniformSquare
}

public struct BroadcastDraggableWidgetOverlay<Content: View>: View {
    @Binding var placement: BroadcastWidgetPlacement
    let isEditing: Bool
    let contentSizing: WidgetOverlayContentSizing
    let contentAspectRatio: CGFloat
    @ViewBuilder let content: () -> Content

    @State private var moveStartPlacement: BroadcastWidgetPlacement?
    @State private var resizeStartPlacement: BroadcastWidgetPlacement?
    @State private var isDragging = false

    private let minSize: CGFloat = 48

    public init(
        placement: Binding<BroadcastWidgetPlacement>,
        isEditing: Bool,
        contentSizing: WidgetOverlayContentSizing = .fillFrame,
        contentAspectRatio: CGFloat = 1,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._placement = placement
        self.isEditing = isEditing
        self.contentSizing = contentSizing
        self.contentAspectRatio = max(contentAspectRatio, 0.01)
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            let canvasSize = geometry.size
            let rect = WidgetPlacementGeometry.rect(
                from: placement,
                canvas: canvasSize,
                sizing: contentSizing
            )

            ZStack {
                content()
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .allowsHitTesting(false)

                if isEditing {
                    editingChrome(canvasSize: canvasSize, rect: rect)
                }
            }
        }
        .allowsHitTesting(isEditing)
    }

    @ViewBuilder
    private func editingChrome(canvasSize: CGSize, rect: CGRect) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .strokeBorder(Color.white.opacity(0.95), lineWidth: 1.5)
            .shadow(color: BroadcastTheme.studioAccent.opacity(0.35), radius: 6)
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(false)

        Color.clear
            .frame(width: rect.width, height: rect.height)
            .contentShape(Rectangle())
            .position(x: rect.midX, y: rect.midY)
            .gesture(moveGesture(canvasSize: canvasSize))
#if os(macOS)
            .onHover { hovering in
                if hovering, !isDragging { NSCursor.openHand.push() }
                else { NSCursor.pop() }
            }
#endif

        ForEach(WidgetResizeCorner.allCases, id: \.self) { corner in
            WidgetCornerHandle()
                .frame(
                    width: WidgetPlacementChrome.handleHitSize,
                    height: WidgetPlacementChrome.handleHitSize
                )
                .contentShape(Rectangle())
                .position(x: corner.point(in: rect).x, y: corner.point(in: rect).y)
                .gesture(resizeGesture(canvasSize: canvasSize, corner: corner))
#if os(macOS)
                .onHover { hovering in
                    if hovering { corner.pushCursor() } else { NSCursor.pop() }
                }
#endif
        }
    }

    private func moveGesture(canvasSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .local)
            .onChanged { value in
                guard isEditing else { return }
                if moveStartPlacement == nil {
                    moveStartPlacement = placement
                    isDragging = true
#if os(macOS)
                    NSCursor.closedHand.push()
#endif
                }
                guard let start = moveStartPlacement else { return }
                var next = start
                next.normalizedCenterX = min(
                    1,
                    max(0, start.normalizedCenterX + Double(value.translation.width / canvasSize.width))
                )
                next.normalizedCenterY = min(
                    1,
                    max(0, start.normalizedCenterY + Double(value.translation.height / canvasSize.height))
                )
                placement = next
            }
            .onEnded { _ in
                moveStartPlacement = nil
                isDragging = false
#if os(macOS)
                NSCursor.pop()
#endif
            }
    }

    private func resizeGesture(canvasSize: CGSize, corner: WidgetResizeCorner) -> some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                guard isEditing else { return }
                if resizeStartPlacement == nil {
                    resizeStartPlacement = placement
                }
                guard let start = resizeStartPlacement else { return }
                placement = WidgetPlacementGeometry.resized(
                    from: start,
                    corner: corner,
                    translation: value.translation,
                    canvas: canvasSize,
                    sizing: contentSizing,
                    minSize: minSize
                )
            }
            .onEnded { _ in
                resizeStartPlacement = nil
            }
    }
}

// MARK: - Placement geometry (crop-overlay style: anchor opposite corner)

private enum WidgetPlacementGeometry {
    static func rect(
        from placement: BroadcastWidgetPlacement,
        canvas: CGSize,
        sizing: WidgetOverlayContentSizing
    ) -> CGRect {
        guard canvas.width > 0, canvas.height > 0 else { return .zero }

        var width = max(1, canvas.width * placement.widthFraction)
        var height = max(1, canvas.height * placement.heightFraction)
        if sizing == .uniformSquare {
            let side = min(width, height)
            width = side
            height = side
        }

        let centerX = canvas.width * placement.normalizedCenterX
        let centerY = canvas.height * placement.normalizedCenterY
        return CGRect(
            x: centerX - width / 2,
            y: centerY - height / 2,
            width: width,
            height: height
        )
    }

    static func placement(from rect: CGRect, canvas: CGSize) -> BroadcastWidgetPlacement {
        BroadcastWidgetPlacement(
            normalizedCenterX: Double(rect.midX / canvas.width),
            normalizedCenterY: Double(rect.midY / canvas.height),
            widthFraction: Double(rect.width / canvas.width),
            heightFraction: Double(rect.height / canvas.height)
        )
    }

    static func resized(
        from start: BroadcastWidgetPlacement,
        corner: WidgetResizeCorner,
        translation: CGSize,
        canvas: CGSize,
        sizing: WidgetOverlayContentSizing,
        minSize: CGFloat
    ) -> BroadcastWidgetPlacement {
        let startRect = rect(from: start, canvas: canvas, sizing: sizing)
        let anchor = corner.opposite.point(in: startRect)
        var dragged = corner.point(in: startRect)
        dragged.x += translation.width
        dragged.y += translation.height

        var nextRect = rectFromAnchor(anchor: anchor, dragged: dragged, minSize: minSize)

        if sizing == .uniformSquare {
            let side = max(minSize, max(nextRect.width, nextRect.height))
            nextRect = squareRect(fixedCorner: corner.opposite, at: anchor, side: side)
        }

        nextRect = clamp(nextRect, in: canvas, minSize: minSize)
        return placement(from: nextRect, canvas: canvas)
    }

    private static func rectFromAnchor(anchor: CGPoint, dragged: CGPoint, minSize: CGFloat) -> CGRect {
        let minX = min(anchor.x, dragged.x)
        let minY = min(anchor.y, dragged.y)
        let maxX = max(anchor.x, dragged.x)
        let maxY = max(anchor.y, dragged.y)
        return CGRect(
            x: minX,
            y: minY,
            width: max(minSize, maxX - minX),
            height: max(minSize, maxY - minY)
        )
    }

    private static func squareRect(fixedCorner: WidgetResizeCorner, at anchor: CGPoint, side: CGFloat) -> CGRect {
        switch fixedCorner {
        case .topLeading:
            return CGRect(x: anchor.x, y: anchor.y, width: side, height: side)
        case .topTrailing:
            return CGRect(x: anchor.x - side, y: anchor.y, width: side, height: side)
        case .bottomLeading:
            return CGRect(x: anchor.x, y: anchor.y - side, width: side, height: side)
        case .bottomTrailing:
            return CGRect(x: anchor.x - side, y: anchor.y - side, width: side, height: side)
        }
    }

    private static func clamp(_ rect: CGRect, in canvas: CGSize, minSize: CGFloat) -> CGRect {
        var r = rect
        r.size.width = min(canvas.width, max(minSize, r.width))
        r.size.height = min(canvas.height, max(minSize, r.height))

        if r.minX < 0 { r.origin.x = 0 }
        if r.minY < 0 { r.origin.y = 0 }
        if r.maxX > canvas.width { r.origin.x = canvas.width - r.width }
        if r.maxY > canvas.height { r.origin.y = canvas.height - r.height }

        r.origin.x = max(0, min(r.origin.x, canvas.width - r.width))
        r.origin.y = max(0, min(r.origin.y, canvas.height - r.height))
        return r
    }
}

private enum WidgetResizeCorner: CaseIterable {
    case topLeading, topTrailing, bottomLeading, bottomTrailing

    var opposite: WidgetResizeCorner {
        switch self {
        case .topLeading: .bottomTrailing
        case .topTrailing: .bottomLeading
        case .bottomLeading: .topTrailing
        case .bottomTrailing: .topLeading
        }
    }

    func point(in rect: CGRect) -> CGPoint {
        switch self {
        case .topLeading: CGPoint(x: rect.minX, y: rect.minY)
        case .topTrailing: CGPoint(x: rect.maxX, y: rect.minY)
        case .bottomLeading: CGPoint(x: rect.minX, y: rect.maxY)
        case .bottomTrailing: CGPoint(x: rect.maxX, y: rect.maxY)
        }
    }

#if os(macOS)
    func pushCursor() {
        NSCursor.crosshair.push()
    }
#endif
}

private enum WidgetPlacementChrome {
    static let handleHitSize: CGFloat = 48
}

/// Corner resize handle — circular dot only (no L-bars that read as crosses).
private struct WidgetCornerHandle: View {
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.white, Color.white.opacity(0.88)],
                    center: .center,
                    startRadius: 0,
                    endRadius: 8
                )
            )
            .frame(width: 14, height: 14)
            .overlay { Circle().strokeBorder(BroadcastTheme.studioAccent, lineWidth: 2) }
            .shadow(color: BroadcastTheme.studioAccent.opacity(0.5), radius: 4)
    }
}

public struct BroadcastWidgetCanvas: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let isEditing: Bool
    let isLive: Bool
    let allowsMotion: Bool
    @Binding var placement: BroadcastWidgetPlacement
    var onLiveSequenceEnded: (() -> Void)?

    public init(
        configuration: BroadcastWidgetConfiguration,
        logoURL: URL?,
        isEditing: Bool,
        isLive: Bool,
        allowsMotion: Bool = true,
        placement: Binding<BroadcastWidgetPlacement>,
        onLiveSequenceEnded: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.logoURL = logoURL
        self.isEditing = isEditing
        self.isLive = isLive
        self.allowsMotion = allowsMotion
        self._placement = placement
        self.onLiveSequenceEnded = onLiveSequenceEnded
    }

    private var contentSizing: WidgetOverlayContentSizing {
        switch configuration.resolvedTemplate {
        case .animatedLogo, .logo:
            return .uniformSquare
        default:
            return .fillFrame
        }
    }

    private var logoAspectRatio: CGFloat {
        BroadcastWidgetImageLoader.aspectRatio(for: logoURL) ?? 1
    }

    public var body: some View {
        BroadcastDraggableWidgetOverlay(
            placement: $placement,
            isEditing: isEditing,
            contentSizing: contentSizing,
            contentAspectRatio: logoAspectRatio
        ) {
            BroadcastWidgetContentView(
                configuration: configuration,
                logoURL: logoURL,
                isLive: isLive,
                allowsMotion: allowsMotion,
                onLiveSequenceEnded: onLiveSequenceEnded
            )
        }
    }
}

public struct BroadcastWidgetContentView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let isLive: Bool
    let allowsMotion: Bool
    var onLiveSequenceEnded: (() -> Void)?

    public init(
        configuration: BroadcastWidgetConfiguration,
        logoURL: URL?,
        isLive: Bool,
        allowsMotion: Bool = true,
        onLiveSequenceEnded: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.logoURL = logoURL
        self.isLive = isLive
        self.allowsMotion = allowsMotion
        self.onLiveSequenceEnded = onLiveSequenceEnded
    }

    public var body: some View {
        switch configuration.resolvedTemplate {
        case .animatedLogo, .logo:
            AnimatedLogoWidgetView(
                configuration: configuration,
                logoURL: logoURL,
                allowsMotion: allowsMotion
            )
        case .ticker, .textBanner:
            TickerWidgetView(configuration: configuration)
        case .lowerThirdPro, .lowerThird:
            LowerThirdProWidgetView(
                configuration: configuration,
                logoURL: logoURL,
                isLive: isLive,
                onLiveSequenceEnded: onLiveSequenceEnded
            )
        case .clock:
            ClockWidgetView(configuration: configuration)
        case .countdown:
            CountdownWidgetView(configuration: configuration, isLive: isLive)
        }
    }
}

// MARK: - Animated Logo

private enum LogoAnimationCycle {
    static func state(time: TimeInterval, speed: Double) -> (isActive: Bool, progress: Double, idlePhase: Double) {
        let cycleDuration = max(3.5, 5.0 / speed)
        let activeDuration = min(1.4 / speed, cycleDuration * 0.35)
        let t = time.truncatingRemainder(dividingBy: cycleDuration)
        let idlePhase = time * 0.15
        if t < activeDuration {
            return (true, t / activeDuration, idlePhase)
        }
        return (false, 0, idlePhase)
    }
}

private struct AnimatedLogoWidgetView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let allowsMotion: Bool

    var body: some View {
        CachedWidgetLogoView(logoURL: logoURL) { image in
            LogoMotionContainer(
                allowsMotion: allowsMotion,
                configuration: configuration,
                content: image
                    .resizable()
                    .scaledToFit()
            )
        } placeholder: {
            LogoMotionContainer(
                allowsMotion: allowsMotion,
                configuration: configuration,
                content: placeholderLogo
            )
        }
    }

    private var placeholderLogo: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(BroadcastWidgetColors.color(hex: configuration.accentColorHex).opacity(0.35))
            .overlay {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.8))
            }
    }
}

private struct LogoMotionContainer<Content: View>: View {
    let allowsMotion: Bool
    let configuration: BroadcastWidgetConfiguration
    let content: Content

    var body: some View {
        if allowsMotion {
            TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate * configuration.animationSpeed
                content
                    .modifier(LogoAnimationModifier(
                        kind: configuration.logoAnimation,
                        time: time,
                        speed: configuration.animationSpeed
                    ))
            }
        } else {
            content
        }
    }
}

private struct LogoAnimationModifier: ViewModifier {
    let kind: BroadcastLogoAnimation
    let time: TimeInterval
    let speed: Double

    private var anim: (isActive: Bool, progress: Double, idlePhase: Double) {
        LogoAnimationCycle.state(time: time, speed: speed)
    }

    func body(content: Content) -> some View {
        let state = anim
        switch kind {
        case .none:
            content
        case .rotate:
            content
                .rotationEffect(.degrees(state.isActive ? state.progress * 360 : sin(state.idlePhase) * 3))
        case .sphere3D:
            sphereContent(content, state: state)
        case .pulse:
            content
                .scaleEffect(state.isActive ? 1.0 + sin(state.progress * .pi) * 0.1 : 1.0)
        case .float:
            content
                .offset(y: state.isActive ? sin(state.progress * .pi) * -10 : sin(state.idlePhase) * 2)
        case .flip:
            content
                .rotation3DEffect(
                    .degrees(state.isActive ? state.progress * 360 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.55
                )
        }
    }

    @ViewBuilder
    private func sphereContent(_ content: Content, state: (isActive: Bool, progress: Double, idlePhase: Double)) -> some View {
        let spin = state.isActive ? state.progress * 360 : sin(state.idlePhase) * 6
        let tilt = state.isActive ? sin(state.progress * .pi) * 12 : sin(state.idlePhase * 0.7) * 4
        let radians = spin * .pi / 180
        let depthScale = 0.72 + abs(cos(radians)) * 0.28
        let highlightShift = sin(radians) * 0.08

        content
            .scaledToFill()
            .clipShape(Circle())
            .overlay {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.28 + highlightShift),
                                .clear,
                                .black.opacity(0.22 - highlightShift)
                            ],
                            center: UnitPoint(x: 0.32 - highlightShift, y: 0.28),
                            startRadius: 2,
                            endRadius: 120
                        )
                    )
                    .blendMode(.softLight)
            }
            .overlay {
                Circle()
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            }
            .scaleEffect(x: depthScale, y: 1.0)
            .rotation3DEffect(.degrees(spin), axis: (0, 1, 0), perspective: 0.62)
            .rotation3DEffect(.degrees(tilt), axis: (1, 0, 0), perspective: 0.62)
    }
}

// MARK: - Ticker

private struct TickerWidgetView: View {
    let configuration: BroadcastWidgetConfiguration

    private var displayText: String {
        configuration.tickerText.isEmpty
            ? (configuration.tickerTexts.first ?? configuration.title)
            : configuration.tickerText
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
            TickerScrollingContent(
                text: displayText,
                configuration: configuration,
                elapsed: timeline.date.timeIntervalSinceReferenceDate
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

private struct TickerScrollingContent: View {
    let text: String
    let configuration: BroadcastWidgetConfiguration
    let elapsed: TimeInterval

    private let labelSpacing: CGFloat = 64

    private var measuredSegmentWidth: CGFloat {
        BroadcastWidgetTypography.measureTextWidth(
            text,
            preset: configuration.titleFont,
            size: configuration.titleFontSize,
            weight: .semibold
        )
    }

    var body: some View {
        GeometryReader { geo in
            let speed = max(20, configuration.tickerSpeed)
            let period = max(measuredSegmentWidth + labelSpacing, 1)
            let copyCount = max(3, Int(ceil(geo.size.width / period)) + 2)
            let offset = -(elapsed * speed).truncatingRemainder(dividingBy: period)

            ZStack {
                Group {
                    if configuration.resolvedUseTickerGradient {
                        BroadcastWidgetColors.gradient(configuration.tickerGradient)
                    } else {
                        BroadcastWidgetColors.color(
                            hex: configuration.resolvedTickerBackgroundHex,
                            fallback: Color.black.opacity(0.8)
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                HStack(spacing: labelSpacing) {
                    ForEach(0..<copyCount, id: \.self) { _ in
                        tickerLabel
                    }
                }
                .offset(x: offset)
                .frame(maxHeight: .infinity, alignment: .center)
            }
        }
    }

    private var tickerLabel: some View {
        Text(verbatim: text)
            .font(BroadcastWidgetTypography.font(
                configuration.titleFont,
                size: configuration.titleFontSize,
                weight: .semibold
            ))
            .foregroundStyle(BroadcastWidgetColors.color(
                hex: configuration.resolvedTickerTextColorHex,
                fallback: .white
            ))
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 16)
    }
}

// MARK: - Lower Third Pro

private struct LowerThirdProWidgetView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let isLive: Bool
    var onLiveSequenceEnded: (() -> Void)?

    @State private var phase: SequencePhase = .offscreen

    enum SequencePhase: Equatable {
        case offscreen, onscreen
    }

    var body: some View {
        content
            .offset(y: phase == .onscreen ? 0 : 90)
            .opacity(phase == .onscreen ? 1 : 0)
            .onAppear { restartSequenceIfNeeded() }
            .onChange(of: isLive) { _, live in
                if live { restartSequenceIfNeeded() } else { phase = .onscreen }
            }
            .onChange(of: phase) { _, newPhase in
                guard newPhase == .offscreen, isLive, configuration.autoPlaySequence else { return }
                onLiveSequenceEnded?()
            }
    }

    private var content: some View {
        HStack(spacing: 14) {
            CachedWidgetLogoView(logoURL: logoURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } placeholder: {
                Color.clear.frame(width: 52, height: 52)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(configuration.title)
                    .font(BroadcastWidgetTypography.font(
                        configuration.titleFont,
                        size: configuration.titleFontSize,
                        weight: .bold
                    ))
                    .foregroundStyle(BroadcastWidgetColors.color(hex: configuration.resolvedTitleColorHex))
                if let subtitle = configuration.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(BroadcastWidgetTypography.font(
                            configuration.subtitleFont,
                            size: configuration.subtitleFontSize
                        ))
                        .foregroundStyle(BroadcastWidgetColors.color(hex: configuration.resolvedSubtitleColorHex))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background {
            Group {
                if configuration.resolvedUseLowerThirdGradient {
                    BroadcastWidgetColors.gradient(
                        configuration.resolvedLowerThirdGradient(fallbackAccent: configuration.accentColorHex)
                    )
                } else {
                    BroadcastWidgetColors.color(hex: configuration.accentColorHex).opacity(0.92)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
    }

    private func restartSequenceIfNeeded() {
        guard configuration.autoPlaySequence, isLive else {
            phase = .onscreen
            return
        }

        phase = .offscreen
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(60))
            withAnimation(.spring(response: configuration.animateInSeconds, dampingFraction: 0.82)) {
                phase = .onscreen
            }
            try? await Task.sleep(for: .seconds(configuration.holdDurationSeconds))
            withAnimation(.easeInOut(duration: configuration.animateOutSeconds)) {
                phase = .offscreen
            }
        }
    }
}

// MARK: - Clock

private struct ClockWidgetView: View {
    let configuration: BroadcastWidgetConfiguration

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(alignment: .trailing, spacing: 2) {
                Text(timeString(for: context.date))
                    .font(BroadcastWidgetTypography.font(
                        configuration.titleFont,
                        size: configuration.titleFontSize,
                        weight: .bold
                    ))
                    .monospacedDigit()
                if configuration.clockShowsDate {
                    Text(dateString(for: context.date))
                        .font(BroadcastWidgetTypography.font(
                            configuration.subtitleFont,
                            size: configuration.subtitleFontSize
                        ))
                        .opacity(0.85)
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func timeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        if configuration.clockUse24Hour {
            formatter.dateFormat = configuration.clockShowsSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            formatter.dateFormat = configuration.clockShowsSeconds ? "h:mm:ss a" : "h:mm a"
        }
        return formatter.string(from: date)
    }

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Countdown

private struct CountdownWidgetView: View {
    let configuration: BroadcastWidgetConfiguration
    let isLive: Bool

    @State private var remainingSeconds: Int = 0
    @State private var animateToken = 0

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let _ = tick(context.date)
            Text(formattedRemaining)
                .font(BroadcastWidgetTypography.font(
                    configuration.titleFont,
                    size: configuration.titleFontSize,
                    weight: .bold
                ))
                .foregroundStyle(BroadcastWidgetColors.color(hex: configuration.accentColorHex))
                .shadow(color: .black.opacity(0.45), radius: 10)
                .modifier(CountdownAnimationModifier(
                    style: configuration.countdownAnimation,
                    token: animateToken
                ))
                .onChange(of: formattedRemaining) { _, _ in
                    animateToken += 1
                }
        }
        .onAppear { syncRemaining() }
        .onChange(of: configuration.countdownSeconds) { _, _ in syncRemaining() }
        .onChange(of: configuration.countdownTargetDate) { _, _ in syncRemaining() }
    }

    private var formattedRemaining: String {
        let seconds = max(0, remainingSeconds)
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func syncRemaining() {
        if let target = configuration.countdownTargetDate {
            remainingSeconds = max(0, Int(target.timeIntervalSinceNow))
        } else if remainingSeconds == 0 {
            remainingSeconds = max(0, configuration.countdownSeconds)
        }
    }

    private func tick(_ date: Date) {
        if let target = configuration.countdownTargetDate {
            remainingSeconds = max(0, Int(target.timeIntervalSinceNow))
        } else if isLive, remainingSeconds > 0 {
            remainingSeconds -= 1
        } else if !isLive {
            remainingSeconds = max(0, configuration.countdownSeconds)
        }
    }
}

private struct CountdownAnimationModifier: ViewModifier {
    let style: BroadcastCountdownAnimation
    let token: Int

    @State private var animate = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(y: offsetY)
            .rotation3DEffect(.degrees(flipDegrees), axis: (x: 1, y: 0, z: 0))
            .onChange(of: token) { _, _ in
                animate = false
                withAnimation(animation) { animate = true }
            }
            .onAppear {
                withAnimation(animation) { animate = true }
            }
    }

    private var animation: Animation {
        switch style {
        case .fadeScale: .spring(response: 0.45, dampingFraction: 0.72)
        case .flipClock: .easeInOut(duration: 0.35)
        case .slideUp: .spring(response: 0.5, dampingFraction: 0.8)
        case .bounce: .interpolatingSpring(stiffness: 220, damping: 12)
        }
    }

    private var scale: CGFloat {
        guard style == .fadeScale || style == .bounce else { return 1 }
        return animate ? 1 : (style == .bounce ? 1.15 : 0.82)
    }

    private var opacity: Double {
        style == .fadeScale ? (animate ? 1 : 0.25) : 1
    }

    private var offsetY: CGFloat {
        style == .slideUp ? (animate ? 0 : 28) : 0
    }

    private var flipDegrees: Double {
        style == .flipClock ? (animate ? 0 : 90) : 0
    }
}

// MARK: - Legacy overlay wrapper

public struct BroadcastWidgetOverlayView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let isLive: Bool

    public init(
        configuration: BroadcastWidgetConfiguration,
        logoURL: URL? = nil,
        isLive: Bool = true
    ) {
        self.configuration = configuration
        self.logoURL = logoURL
        self.isLive = isLive
    }

    public var body: some View {
        GeometryReader { geometry in
            BroadcastWidgetContentView(
                configuration: configuration,
                logoURL: logoURL,
                isLive: isLive
            )
            .frame(
                width: geometry.size.width * configuration.placement.widthFraction,
                height: geometry.size.height * configuration.placement.heightFraction
            )
            .position(
                x: geometry.size.width * configuration.placement.normalizedCenterX,
                y: geometry.size.height * configuration.placement.normalizedCenterY
            )
        }
    }
}
