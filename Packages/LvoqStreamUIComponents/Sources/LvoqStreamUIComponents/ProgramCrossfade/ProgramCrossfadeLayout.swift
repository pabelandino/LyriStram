import SwiftUI

enum ProgramCrossfadeLayout {
    /// Uses the space offered by the parent. The director's 16:9 well proposes 16:9;
    /// the external program window proposes the full screen so the picture has no bars.
    static func boundedSize(for proposal: ProposedViewSize) -> CGSize? {
        guard let width = proposal.width, let height = proposal.height,
              width.isFinite, height.isFinite, width > 0, height > 0 else {
            return CGSize(width: 16, height: 9)
        }
        return CGSize(width: width, height: height)
    }
}
