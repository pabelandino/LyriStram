import SwiftUI

enum VideoPreviewLayout {
    static func boundedSize(for proposal: ProposedViewSize) -> CGSize? {
        guard let width = proposal.width, let height = proposal.height else {
            return nil
        }
        return CGSize(width: width, height: height)
    }
}
