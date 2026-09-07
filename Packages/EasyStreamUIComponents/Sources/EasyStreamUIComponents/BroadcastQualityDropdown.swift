import SwiftUI
import EasyStreamCore

public struct BroadcastQualityDropdown<Option: Identifiable & Hashable>: View {
    let title: String
    let systemImage: String
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String
    let chips: (Option) -> [BroadcastSpecChipModel]
    let tags: (Option) -> [BroadcastPlatform]

    public init(
        title: String,
        systemImage: String,
        options: [Option],
        selection: Binding<Option>,
        label: @escaping (Option) -> String,
        chips: @escaping (Option) -> [BroadcastSpecChipModel],
        tags: @escaping (Option) -> [BroadcastPlatform] = { _ in [] }
    ) {
        self.title = title
        self.systemImage = systemImage
        self.options = options
        _selection = selection
        self.label = label
        self.chips = chips
        self.tags = tags
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(BroadcastTheme.studioAccent)
                    .frame(width: 24, height: 24)
                    .background(BroadcastTheme.studioAccent.opacity(0.14), in: RoundedRectangle(cornerRadius: 6, style: .continuous))

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BroadcastTheme.primaryText)

                Spacer(minLength: 0)
            }

            Menu {
                ForEach(options) { option in
                    Button {
                        selection = option
                    } label: {
                        if option == selection {
                            Label(label(option), systemImage: "checkmark")
                        } else {
                            Text(label(option))
                        }
                    }
                }
            } label: {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(label(selection))
                            .font(.body.weight(.semibold))
                            .foregroundStyle(BroadcastTheme.primaryText)

                        BroadcastSpecChipRow(models: chips(selection))
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BroadcastTheme.subtleText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BroadcastTheme.panelBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .menuStyle(.borderlessButton)

            if !tags(selection).isEmpty {
                BroadcastPlatformTagRow(platforms: tags(selection))
                    .padding(.leading, 2)
            }
        }
    }
}
