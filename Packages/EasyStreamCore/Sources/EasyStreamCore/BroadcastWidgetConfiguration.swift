import Foundation

public enum BroadcastWidgetTemplate: String, Codable, Sendable, CaseIterable {
    case animatedLogo
    case ticker
    case lowerThirdPro
    case clock
    case countdown

    // Legacy templates (decoded from older saves)
    case lowerThird
    case logo
    case textBanner

    public static var mentoTemplates: [BroadcastWidgetTemplate] {
        [.animatedLogo, .ticker, .lowerThirdPro, .clock, .countdown]
    }

    public var title: String {
        switch self {
        case .animatedLogo, .logo: "Logo animado"
        case .ticker, .textBanner: "Ticker infinito"
        case .lowerThirdPro, .lowerThird: "Lower third pro"
        case .clock: "Hora"
        case .countdown: "Cuenta regresiva"
        }
    }

    public var systemImage: String {
        switch self {
        case .animatedLogo, .logo: "sparkles.rectangle.stack"
        case .ticker, .textBanner: "text.append"
        case .lowerThirdPro, .lowerThird: "rectangle.bottomhalf.inset.filled"
        case .clock: "clock.fill"
        case .countdown: "timer"
        }
    }

    public var resolved: BroadcastWidgetTemplate {
        switch self {
        case .lowerThird: .lowerThirdPro
        case .logo: .animatedLogo
        case .textBanner: .ticker
        default: self
        }
    }
}

public enum BroadcastFontPreset: String, Codable, CaseIterable, Sendable {
    case system
    case rounded
    case serif
    case monospaced
    case condensed
    case boldDisplay

    public var displayName: String {
        switch self {
        case .system: "Sistema"
        case .rounded: "Redondeada"
        case .serif: "Serif"
        case .monospaced: "Monoespaciada"
        case .condensed: "Condensada"
        case .boldDisplay: "Display bold"
        }
    }
}

public enum BroadcastLogoAnimation: String, CaseIterable, Sendable {
    case none
    case rotate
    case sphere3D
    case pulse
    case float
    case flip

    public var displayName: String {
        switch self {
        case .none: "Sin animación"
        case .rotate: "Rotación"
        case .sphere3D: "Esfera 3D"
        case .pulse: "Pulso"
        case .float: "Flotante"
        case .flip: "Volteo"
        }
    }
}

extension BroadcastLogoAnimation: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if raw == "cube3D" {
            self = .sphere3D
        } else {
            self = BroadcastLogoAnimation(rawValue: raw) ?? .none
        }
    }
}

public enum BroadcastCountdownAnimation: String, Codable, CaseIterable, Sendable {
    case fadeScale
    case flipClock
    case slideUp
    case bounce

    public var displayName: String {
        switch self {
        case .fadeScale: "Fade + escala"
        case .flipClock: "Flip reloj"
        case .slideUp: "Deslizar arriba"
        case .bounce: "Rebote"
        }
    }
}

public struct BroadcastWidgetPlacement: Codable, Equatable, Sendable {
    public var normalizedCenterX: Double
    public var normalizedCenterY: Double
    public var widthFraction: Double
    public var heightFraction: Double

    public init(
        normalizedCenterX: Double = 0.5,
        normalizedCenterY: Double = 0.5,
        widthFraction: Double = 0.22,
        heightFraction: Double = 0.22
    ) {
        self.normalizedCenterX = normalizedCenterX
        self.normalizedCenterY = normalizedCenterY
        self.widthFraction = widthFraction
        self.heightFraction = heightFraction
    }

    public static let bottomTicker = BroadcastWidgetPlacement(
        normalizedCenterX: 0.5,
        normalizedCenterY: 0.92,
        widthFraction: 1.0,
        heightFraction: 0.1
    )

    public static let lowerThird = BroadcastWidgetPlacement(
        normalizedCenterX: 0.5,
        normalizedCenterY: 0.82,
        widthFraction: 0.88,
        heightFraction: 0.18
    )
}

public struct BroadcastGradientStyle: Codable, Equatable, Sendable {
    public var startColorHex: String
    public var endColorHex: String
    public var angleDegrees: Double

    public init(
        startColorHex: String = "007AFF",
        endColorHex: String = "5856D6",
        angleDegrees: Double = 0
    ) {
        self.startColorHex = startColorHex
        self.endColorHex = endColorHex
        self.angleDegrees = angleDegrees
    }
}

public struct BroadcastWidgetConfiguration: Codable, Equatable, Sendable {
    public var template: BroadcastWidgetTemplate
    public var title: String
    public var subtitle: String?
    public var accentColorHex: String?

    public var titleFont: BroadcastFontPreset
    public var subtitleFont: BroadcastFontPreset
    public var titleFontSize: Double
    public var subtitleFontSize: Double

    public var placement: BroadcastWidgetPlacement

    public var logoFileName: String?
    public var logoAnimation: BroadcastLogoAnimation
    public var animationSpeed: Double

    public var tickerText: String
    public var tickerTexts: [String]
    public var tickerGradient: BroadcastGradientStyle
    public var tickerBackgroundHex: String?
    public var tickerTextColorHex: String?
    public var tickerSpeed: Double

    public var resolvedTickerTextColorHex: String {
        tickerTextColorHex ?? "FFFFFF"
    }

    public var resolvedTickerBackgroundHex: String {
        tickerBackgroundHex ?? "CC000000"
    }

    public var titleColorHex: String?
    public var subtitleColorHex: String?
    public var lowerThirdGradient: BroadcastGradientStyle?
    public var useTickerGradient: Bool?
    public var useLowerThirdGradient: Bool?

    public var resolvedTitleColorHex: String {
        titleColorHex ?? "FFFFFF"
    }

    public var resolvedSubtitleColorHex: String {
        subtitleColorHex ?? "FFFFFFE6"
    }

    public var resolvedUseTickerGradient: Bool {
        useTickerGradient ?? true
    }

    public var resolvedUseLowerThirdGradient: Bool {
        useLowerThirdGradient ?? false
    }

    public func resolvedLowerThirdGradient(fallbackAccent: String?) -> BroadcastGradientStyle {
        if let lowerThirdGradient { return lowerThirdGradient }
        let start = fallbackAccent ?? accentColorHex ?? "007AFF"
        return BroadcastGradientStyle(startColorHex: start, endColorHex: "5856D6", angleDegrees: 12)
    }

    public var holdDurationSeconds: Double
    public var animateInSeconds: Double
    public var animateOutSeconds: Double
    public var autoPlaySequence: Bool

    public var clockShowsSeconds: Bool
    public var clockShowsDate: Bool
    public var clockUse24Hour: Bool

    public var countdownTargetDate: Date?
    public var countdownSeconds: Int
    public var countdownAnimation: BroadcastCountdownAnimation

    public var resolvedTemplate: BroadcastWidgetTemplate {
        template.resolved
    }

    public init(
        template: BroadcastWidgetTemplate = .animatedLogo,
        title: String = "Título",
        subtitle: String? = nil,
        accentColorHex: String? = "007AFF"
    ) {
        self.template = template
        self.title = title
        self.subtitle = subtitle
        self.accentColorHex = accentColorHex
        self.titleFont = .boldDisplay
        self.subtitleFont = .system
        self.titleFontSize = 28
        self.subtitleFontSize = 16
        self.placement = Self.defaultPlacement(for: template.resolved)
        self.logoFileName = nil
        self.logoAnimation = .sphere3D
        self.animationSpeed = 1.0
        self.tickerText = title
        self.tickerTexts = [title]
        self.tickerGradient = BroadcastGradientStyle(startColorHex: accentColorHex ?? "007AFF", endColorHex: "5856D6")
        self.tickerBackgroundHex = "CC000000"
        self.tickerTextColorHex = "FFFFFF"
        self.tickerSpeed = 80
        self.titleColorHex = "FFFFFF"
        self.subtitleColorHex = "FFFFFFE6"
        self.lowerThirdGradient = nil
        self.useTickerGradient = true
        self.useLowerThirdGradient = false
        self.holdDurationSeconds = 5
        self.animateInSeconds = 0.65
        self.animateOutSeconds = 0.55
        self.autoPlaySequence = true
        self.clockShowsSeconds = true
        self.clockShowsDate = false
        self.clockUse24Hour = true
        self.countdownTargetDate = nil
        self.countdownSeconds = 60
        self.countdownAnimation = .fadeScale
    }

    public static func defaultPlacement(for template: BroadcastWidgetTemplate) -> BroadcastWidgetPlacement {
        switch template {
        case .animatedLogo, .logo:
            BroadcastWidgetPlacement(normalizedCenterX: 0.12, normalizedCenterY: 0.12, widthFraction: 0.18, heightFraction: 0.18)
        case .ticker, .textBanner:
            .bottomTicker
        case .lowerThirdPro, .lowerThird:
            .lowerThird
        case .clock:
            BroadcastWidgetPlacement(normalizedCenterX: 0.88, normalizedCenterY: 0.1, widthFraction: 0.28, heightFraction: 0.12)
        case .countdown:
            BroadcastWidgetPlacement(normalizedCenterX: 0.5, normalizedCenterY: 0.5, widthFraction: 0.5, heightFraction: 0.35)
        }
    }

    public mutating func applyTemplateDefaults() {
        placement = Self.defaultPlacement(for: template.resolved)
        switch template.resolved {
        case .animatedLogo, .logo:
            logoAnimation = .sphere3D
        case .ticker, .textBanner:
            if tickerText.isEmpty { tickerText = title }
            tickerTexts = [tickerText]
            if tickerBackgroundHex == nil { tickerBackgroundHex = "CC000000" }
            if tickerTextColorHex == nil { tickerTextColorHex = "FFFFFF" }
        case .lowerThirdPro, .lowerThird:
            autoPlaySequence = true
        case .clock:
            titleFont = .monospaced
        case .countdown:
            titleFont = .rounded
            titleFontSize = 72
        }
    }
}
