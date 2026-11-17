import SwiftUI

public struct BroadcastFormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    public init(_ title: String, text: Binding<String>, placeholder: String) {
        self.title = title
        _text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
#if os(iOS)
                .textInputAutocapitalization(.never)
#endif
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(BroadcastTheme.panelBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
