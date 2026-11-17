import SwiftUI

public struct BroadcastTallyPill: View {
    let label: String
    let color: Color

    public init(_ label: String, color: Color) {
        self.label = label
        self.color = color
    }

    public var body: some View {
        Text(label)
            .font(.caption2.weight(.black))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.18), in: Capsule())
            .overlay(Capsule().strokeBorder(color.opacity(0.65), lineWidth: 1))
            .foregroundStyle(color)
    }
}
