import SwiftUI

struct BroadcastSpecChip: View {
    let text: String
    var tint: Color = BroadcastTheme.subtleText

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(tint.opacity(0.95))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(tint.opacity(0.14), in: Capsule())
    }
}
