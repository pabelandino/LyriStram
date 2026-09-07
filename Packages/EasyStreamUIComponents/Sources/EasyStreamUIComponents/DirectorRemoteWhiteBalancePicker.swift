import SwiftUI
import EasyStreamCore

struct DirectorRemoteWhiteBalancePicker: View {
    let mode: RemoteWhiteBalanceOption
    let onWhiteBalanceChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Balance de blancos")
                .font(.subheadline.weight(.semibold))
            Picker("Balance de blancos", selection: Binding(
                get: { mode },
                set: { onWhiteBalanceChange($0.rawValue) }
            )) {
                ForEach(RemoteWhiteBalanceOption.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.menu)
        }
    }
}
