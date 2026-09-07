import SwiftUI

public struct SignalStrengthView: View {
    let level: Int

    public init(level: Int) {
        self.level = max(0, min(level, 4))
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(index < level ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 4, height: CGFloat(6 + index * 3))
            }
        }
        .accessibilityLabel("Señal de red")
    }
}
