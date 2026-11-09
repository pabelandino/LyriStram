import SwiftUI
import EasyStreamCore

struct LyrioraWidgetPlateView: View {
    let configuration: BroadcastWidgetConfiguration
    let headline: String
    let bodyText: String
    let showsPlaceholder: Bool

    private var isFullScreen: Bool { configuration.resolvedLyrioraMode == .fullScreen }

    /// Lower thirds refill the plate. Full screen keeps Lyriora's line breaks.
    private var displayedBody: String {
        guard !isFullScreen else { return bodyText }
        return bodyText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    var body: some View {
        VStack(alignment: .center, spacing: isFullScreen ? 18 : 8) {
            if !headline.isEmpty {
                Text(headline)
                    .font(headlineFont)
                    .foregroundStyle(headlineColor)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            Text(showsPlaceholder ? "Esperando texto de Lyriora" : displayedBody)
                .font(bodyFont)
                .foregroundStyle(showsPlaceholder ? bodyColor.opacity(0.55) : bodyColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, isFullScreen ? 48 : 28)
        .padding(.vertical, isFullScreen ? 36 : 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background {
            if isFullScreen {
                Rectangle().fill(opaquePlateColor)
            } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(plateColor)
                .overlay {
                    ZStack {
                        if configuration.resolvedLyrioraStyle == .studio {
                            HStack {
                                Rectangle()
                                    .fill(Color(red: 0.24, green: 1, blue: 0.54))
                                    .frame(width: 8)
                                Spacer()
                            }
                        }
                        if configuration.resolvedLyrioraStyle == .liturgical {
                            VStack {
                                Rectangle()
                                    .fill(Color(red: 0.90, green: 0.76, blue: 0.42))
                                    .frame(height: 2)
                                Spacer()
                                Rectangle()
                                    .fill(Color(red: 0.90, green: 0.76, blue: 0.42))
                                    .frame(height: 2)
                            }
                        }
                    }
                }
            }
        }
    }

    private var opaquePlateColor: Color {
        switch configuration.resolvedLyrioraStyle {
        case .classic:
            Color(red: 0.06, green: 0.06, blue: 0.06)
        case .studio:
            Color(red: 0.05, green: 0.07, blue: 0.12)
        case .liturgical:
            Color(red: 0.08, green: 0.05, blue: 0.03)
        }
    }

    private var plateColor: Color {
        switch configuration.resolvedLyrioraStyle {
        case .classic:
            Color.black.opacity(0.55)
        case .studio:
            Color(red: 0.05, green: 0.07, blue: 0.12).opacity(0.86)
        case .liturgical:
            Color(red: 0.08, green: 0.05, blue: 0.03).opacity(0.74)
        }
    }

    private var headlineFont: Font {
        switch configuration.resolvedLyrioraStyle {
        case .classic, .liturgical:
            .system(.title3, design: .serif, weight: .semibold)
        case .studio:
            .headline.weight(.bold)
        }
    }

    private var bodyFont: Font {
        switch configuration.resolvedLyrioraStyle {
        case .classic, .liturgical:
            .system(isFullScreen ? .largeTitle : .title2, design: .serif)
        case .studio:
            (isFullScreen ? Font.largeTitle : Font.title3).weight(.semibold)
        }
    }

    private var headlineColor: Color {
        switch configuration.resolvedLyrioraStyle {
        case .classic:
            Color(red: 0.95, green: 0.91, blue: 0.84)
        case .studio:
            Color(red: 0.24, green: 1, blue: 0.54)
        case .liturgical:
            Color(red: 0.90, green: 0.76, blue: 0.42)
        }
    }

    private var bodyColor: Color {
        switch configuration.resolvedLyrioraStyle {
        case .classic, .studio:
            .white
        case .liturgical:
            Color(red: 0.97, green: 0.95, blue: 0.89)
        }
    }
}
