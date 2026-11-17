import SwiftUI

public struct BroadcastSpecChipModel: Hashable {
    public let text: String
    public let tint: Color

    public init(_ text: String, tint: Color = BroadcastTheme.subtleText) {
        self.text = text
        self.tint = tint
    }
}
