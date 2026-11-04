import SwiftUI
import EasyStreamCore

struct LowerThirdAngularBarsView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let logoShown: Bool
    let barsShown: [Bool]

    private var pieces: [LowerThirdPiece] {
        LowerThirdLayout.pieces(
            style: .angular,
            hasThirdLine: !configuration.lowerThirdThirdLine.isEmpty
        )
    }

    var body: some View {
        GeometryReader { geo in
            let scaleX = geo.size.width / LowerThirdLayout.width
            let scaleY = geo.size.height / LowerThirdLayout.height
            ZStack {
                ForEach(pieces) { piece in
                    pieceView(piece, scale: scaleY)
                        .frame(width: piece.frame.width * scaleX, height: piece.frame.height * scaleY)
                        .scaleEffect(piece.kind == .logo ? (shown(piece) ? 1 : 0.84) : 1, anchor: .leading)
                        .offset(x: shown(piece) ? 0 : slide(for: piece, scaleX: scaleX))
                        .opacity(shown(piece) ? 1 : 0)
                        .position(
                            x: (piece.frame.x + piece.frame.width / 2) * scaleX,
                            y: (piece.frame.y + piece.frame.height / 2) * scaleY
                        )
                }
            }
        }
    }

    private func shown(_ piece: LowerThirdPiece) -> Bool {
        if piece.kind == .logo { return logoShown }
        guard piece.barIndex >= 0, piece.barIndex < barsShown.count else { return false }
        return barsShown[piece.barIndex]
    }

    private func slide(for piece: LowerThirdPiece, scaleX: CGFloat) -> CGFloat {
        if piece.kind == .logo {
            return -piece.frame.width * scaleX * 0.32
        }
        return -piece.frame.width * scaleX
    }

    @ViewBuilder
    private func pieceView(_ piece: LowerThirdPiece, scale: CGFloat) -> some View {
        switch piece.kind {
        case .logo:
            logoPlate(height: piece.frame.height * scale)
        case .lightBar:
            bar(
                text: configuration.title,
                hex: LowerThirdContrast.textHex(configuration.resolvedTitleColorHex, on: "FFFFFF"),
                fill: AnyShapeStyle(Color.white),
                font: configuration.titleFont,
                size: piece.frame.height * scale * 0.46 * fontScale,
                weight: .bold
            )
        case .darkBar:
            bar(
                text: configuration.subtitle ?? "",
                hex: LowerThirdContrast.textHex(configuration.resolvedSubtitleColorHex, on: "2C2C2E"),
                fill: AnyShapeStyle(Color(red: 0.17, green: 0.17, blue: 0.18)),
                font: configuration.subtitleFont,
                size: piece.frame.height * scale * 0.40 * subtitleScale,
                weight: .semibold
            )
        case .accentBar:
            bar(
                text: configuration.lowerThirdThirdLine,
                hex: LowerThirdContrast.textHex(configuration.resolvedTitleColorHex, on: accentHex),
                fill: accentFill,
                font: configuration.titleFont,
                size: piece.frame.height * scale * 0.46 * fontScale,
                weight: .bold
            )
        default:
            Color.clear
        }
    }

    private var fontScale: CGFloat {
        CGFloat(configuration.titleFontSize / 28)
    }

    private var subtitleScale: CGFloat {
        CGFloat(configuration.subtitleFontSize / 16)
    }

    private var accentHex: String {
        configuration.accentColorHex ?? "E6A817"
    }

    private var accentFill: AnyShapeStyle {
        if configuration.resolvedUseLowerThirdGradient {
            AnyShapeStyle(BroadcastWidgetColors.gradient(
                configuration.resolvedLowerThirdGradient(fallbackAccent: accentHex)
            ))
        } else {
            AnyShapeStyle(BroadcastWidgetColors.color(hex: accentHex))
        }
    }

    private func logoPlate(height: CGFloat) -> some View {
        ZStack {
            LogoPlateShape()
                .fill(Color.black.opacity(0.38))
                .offset(x: height * 0.04, y: height * 0.05)
            LogoPlateShape()
                .fill(accentFill)
            logoMark
                .padding(height * 0.14)
                .clipShape(LogoPlateShape())
        }
    }

    @ViewBuilder
    private var logoMark: some View {
        CachedWidgetLogoView(logoURL: logoURL) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } placeholder: {
            Color.clear
        }
    }

    private func bar(
        text: String,
        hex: String,
        fill: AnyShapeStyle,
        font: BroadcastFontPreset,
        size: CGFloat,
        weight: Font.Weight
    ) -> some View {
        Text(text)
            .font(BroadcastWidgetTypography.font(font, size: size, weight: weight))
            .foregroundStyle(BroadcastWidgetColors.color(hex: hex))
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .padding(.leading, size * 1.15)
            .padding(.trailing, size * 0.8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                SlantedBarShape().fill(fill)
            }
    }
}

private struct SlantedBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let skew = min(rect.height * 0.72, 36)
        var path = Path()
        path.move(to: CGPoint(x: skew, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width - skew, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

private struct LogoPlateShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.06, y: rect.height * 0.16))
        path.addLine(to: CGPoint(x: rect.width * 0.70, y: rect.height * 0.05))
        path.addLine(to: CGPoint(x: rect.width * 0.97, y: rect.height * 0.50))
        path.addLine(to: CGPoint(x: rect.width * 0.70, y: rect.height * 0.95))
        path.addLine(to: CGPoint(x: rect.width * 0.06, y: rect.height * 0.84))
        path.closeSubpath()
        return path
    }
}
