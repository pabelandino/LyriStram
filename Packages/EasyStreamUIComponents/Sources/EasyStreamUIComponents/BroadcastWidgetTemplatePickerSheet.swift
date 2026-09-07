import SwiftUI
import EasyStreamCore

public struct BroadcastWidgetTemplatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (BroadcastWidgetTemplate) -> Void

    public init(onSelect: @escaping (BroadcastWidgetTemplate) -> Void) {
        self.onSelect = onSelect
    }

    public var body: some View {
        NavigationStack {
            List(BroadcastWidgetTemplate.mentoTemplates, id: \.self) { template in
                Button {
                    onSelect(template)
                    dismiss()
                } label: {
                    Label(template.title, systemImage: template.systemImage)
                }
            }
            .navigationTitle("Nuevo widget Mento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 360, minHeight: 320)
#endif
    }
}
