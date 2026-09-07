import SwiftUI
import EasyStreamCore

enum BroadcastWidgetStudioGradientBindings {
    static func useTickerGradient(_ configuration: Binding<BroadcastWidgetConfiguration>) -> Binding<Bool> {
        Binding(
            get: { configuration.wrappedValue.resolvedUseTickerGradient },
            set: { configuration.wrappedValue.useTickerGradient = $0 }
        )
    }

    static func useLowerThirdGradient(_ configuration: Binding<BroadcastWidgetConfiguration>) -> Binding<Bool> {
        Binding(
            get: { configuration.wrappedValue.resolvedUseLowerThirdGradient },
            set: { configuration.wrappedValue.useLowerThirdGradient = $0 }
        )
    }

    static func tickerGradientStart(_ configuration: Binding<BroadcastWidgetConfiguration>) -> Binding<String> {
        Binding(
            get: { configuration.wrappedValue.tickerGradient.startColorHex },
            set: { configuration.wrappedValue.tickerGradient.startColorHex = $0 }
        )
    }

    static func tickerGradientEnd(_ configuration: Binding<BroadcastWidgetConfiguration>) -> Binding<String> {
        Binding(
            get: { configuration.wrappedValue.tickerGradient.endColorHex },
            set: { configuration.wrappedValue.tickerGradient.endColorHex = $0 }
        )
    }

    static func lowerThirdGradient(_ configuration: Binding<BroadcastWidgetConfiguration>) -> Binding<BroadcastGradientStyle> {
        Binding(
            get: {
                configuration.wrappedValue.lowerThirdGradient
                    ?? configuration.wrappedValue.resolvedLowerThirdGradient(
                        fallbackAccent: configuration.wrappedValue.accentColorHex
                    )
            },
            set: { configuration.wrappedValue.lowerThirdGradient = $0 }
        )
    }

    static func lowerThirdGradientStart(_ configuration: Binding<BroadcastWidgetConfiguration>) -> Binding<String> {
        let gradient = lowerThirdGradient(configuration)
        return Binding(
            get: { gradient.wrappedValue.startColorHex },
            set: { gradient.wrappedValue.startColorHex = $0 }
        )
    }

    static func lowerThirdGradientEnd(_ configuration: Binding<BroadcastWidgetConfiguration>) -> Binding<String> {
        let gradient = lowerThirdGradient(configuration)
        return Binding(
            get: { gradient.wrappedValue.endColorHex },
            set: { gradient.wrappedValue.endColorHex = $0 }
        )
    }
}
