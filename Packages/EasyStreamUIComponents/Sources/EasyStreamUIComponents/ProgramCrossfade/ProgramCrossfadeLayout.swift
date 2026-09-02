import SwiftUI

enum ProgramCrossfadeLayout {
    static func boundedSize(for proposal: ProposedViewSize) -> CGSize? {
        guard let width = proposal.width, let height = proposal.height else { return nil }
        return CGSize(width: width, height: height)
    }
}
