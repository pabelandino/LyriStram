import SwiftUI
import EasyStreamCore

struct LowerThirdTitlePlateView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let logoShown: Bool
    let barsShown: [Bool]

    private var pieces: [LowerThirdPiece] {
        LowerThirdLayout.pieces(style: .titlePlate, hasThirdLine: false)
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
        return barsShown.first ?? false
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
            square(height: piece.frame.height * scale)
        case .titleBlock:
            titleBlock(height: piece.frame.height * scale)
        default:
            Color.clear
        }
    }

    private var accentHex: String {
        configuration.accentColorHex ?? "F5C400"
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

    private func square(height: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Rectangle().fill(accentFill)
            VStack(alignment: .leading, spacing: 6) {
                if logoURL != nil {
                    CachedWidgetLogoView(logoURL: logoURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: height * 0.28)
                    } placeholder: {
                        Color.clear.frame(height: 0)
                    }
                }
                Text((configuration.subtitle ?? configuration.title).uppercased())
                    .font(BroadcastWidgetTypography.font(
                        configuration.subtitleFont,
                        size: height * 0.2 * CGFloat(configuration.subtitleFontSize / 16),
                        weight: .bold
                    ))
                    .foregroundStyle(BroadcastWidgetColors.color(
                        hex: LowerThirdContrast.textHex(configuration.resolvedSubtitleColorHex, on: accentHex)
                    ))
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            }
            .padding(height * 0.12)
        }
    }

    private func titleBlock(height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: height * 0.08) {
            Rectangle()
                .fill(Color.white)
                .frame(height: max(3, height * 0.055))
            Text(configuration.title.uppercased())
                .font(BroadcastWidgetTypography.font(
                    configuration.titleFont,
                    size: height * 0.42 * CGFloat(configuration.titleFontSize / 28),
                    weight: .black
                ))
                .foregroundStyle(BroadcastWidgetColors.color(hex: configuration.resolvedTitleColorHex))
                .lineLimit(2)
                .minimumScaleFactor(0.4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
