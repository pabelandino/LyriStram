import SwiftUI
import EasyStreamCore
#if os(iOS)
import UIKit
#endif

public struct TakeToProgramButton: View {
    let isEnabled: Bool
    let action: () -> Void

    @State private var isHovered = false
    @State private var isPressing = false

    public init(isEnabled: Bool, action: @escaping () -> Void) {
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button {
#if os(iOS)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
#endif
            action()
        }         label: {
            Label(BroadcastTerminology.takeAction, systemImage: "arrow.up.right.square.fill")
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
        }
        .buttonStyle(BroadcastTakeButtonStyle(isHovered: isHovered, isPressing: isPressing))
        .onHover { isHovered = $0 }
        .simultaneousGesture(pressGesture)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }

    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard isEnabled else { return }
                isPressing = true
            }
            .onEnded { _ in
                isPressing = false
            }
    }
}

// Legacy alias kept for compatibility during UI migration.
public typealias CutButton = TakeToProgramButton
