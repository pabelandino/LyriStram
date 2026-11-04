import SwiftUI
import EasyStreamCore

struct LowerThirdGuestPlateView: View {
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let logoShown: Bool
    let barsShown: [Bool]

    private var pieces: [LowerThirdPiece] {
        let style: BroadcastLowerThirdStyle = configuration.resolvedLowerThirdStyle == .guestPlain ? .guestPlain : .guest
        return LowerThirdLayout.pieces(style: style, hasThirdLine: false)
    }

    var body: some View {
        GeometryReader { geo in
            let scaleX = geo.size.width / LowerThirdLayout.width
            let scaleY = geo.size.height / LowerThirdLayout.height
            ZStack {
                ForEach(pieces) { piece in
                    pieceView(piece, scale: min(scaleX, scaleY))
                        .frame(width: piece.frame.width * scaleX, height: piece.frame.height * scaleY)
                        .scaleEffect(piece.kind == .logo ? (shown(piece) ? 1 : 0.84) : 1, anchor: .center)
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
            portrait(side: piece.frame.width * scale)
        case .nameBlock:
            nameBlock(height: piece.frame.height * scale)
        default:
            Color.clear
        }
    }

    private var accentHex: String {
        configuration.accentColorHex ?? "3DFF8A"
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

    private func portrait(side: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(
                    BroadcastWidgetColors.color(hex: accentHex),
                    style: StrokeStyle(lineWidth: max(3, side * 0.035), dash: [side * 0.045, side * 0.03])
                )
            CachedWidgetLogoView(logoURL: logoURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } placeholder: {
                Image(systemName: "person.fill")
                    .font(.system(size: side * 0.34, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.12, green: 0.14, blue: 0.12))
            }
            .padding(side * 0.07)
            .clipShape(Circle())
        }
    }

    private func nameBlock(height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: height * 0.06) {
            Text((configuration.subtitle ?? "").uppercased())
                .font(BroadcastWidgetTypography.font(
                    configuration.subtitleFont,
                    size: height * 0.12 * CGFloat(configuration.subtitleFontSize / 16),
                    weight: .semibold
                ))
                .foregroundStyle(BroadcastWidgetColors.color(hex: configuration.resolvedSubtitleColorHex))
                .tracking(1.4)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .shadow(color: .black.opacity(0.45), radius: 2, y: 1)
                .padding(.leading, height * 0.08)
            Text(configuration.title)
                .font(BroadcastWidgetTypography.font(
                    configuration.titleFont,
                    size: height * 0.34 * CGFloat(configuration.titleFontSize / 28),
                    weight: .black
                ))
                .foregroundStyle(BroadcastWidgetColors.color(
                    hex: LowerThirdContrast.textHex(configuration.resolvedTitleColorHex, on: accentHex)
                ))
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .padding(.horizontal, height * 0.1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(accentFill)
        }
    }
}
