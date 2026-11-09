import SwiftUI

public struct LyrioraAirStatusBadge: View {
    let title: String
    let isOnAir: Bool

    public init(title: String, isOnAir: Bool) {
        self.title = title
        self.isOnAir = isOnAir
    }

    public var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isOnAir ? Color(red: 0.24, green: 1, blue: 0.54) : Color.orange)
                .frame(width: 7, height: 7)
            Text(title)
                .font(.caption2.weight(.semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .foregroundStyle(.white)
        .background(.black.opacity(0.55), in: Capsule())
        .accessibilityLabel(title)
    }
}
