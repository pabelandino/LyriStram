import SwiftUI

struct BroadcastSpecChipRow: View {
    let models: [BroadcastSpecChipModel]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(models, id: \.self) { model in
                BroadcastSpecChip(text: model.text, tint: model.tint)
            }
        }
    }
}
