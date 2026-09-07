import SwiftUI
import EasyStreamCore

struct DirectorRemoteLensPicker: View {
    let activeLens: RemoteLensOption
    let onLensChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cámara")
                .font(.subheadline.weight(.semibold))
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(RemoteLensOption.allCases) { lens in
                        Button {
                            onLensChange(lens.rawValue)
                        } label: {
                            Text(lens.displayName)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    activeLens == lens ? BroadcastTheme.studioAccent : BroadcastTheme.panelElevated,
                                    in: Capsule()
                                )
                                .foregroundStyle(activeLens == lens ? Color.white : BroadcastTheme.primaryText)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
