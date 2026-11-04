import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Studio tab — live output only. Day-to-day controls live on the library rail.
struct DirectorSettingsStudioTab: View {
    let viewModel: DirectorSessionViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            DirectorSettingsEmissionSection(viewModel: viewModel)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
