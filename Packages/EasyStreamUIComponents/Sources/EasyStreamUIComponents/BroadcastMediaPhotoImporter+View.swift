import SwiftUI
import EasyStreamCore

public extension View {
#if os(iOS)
    func broadcastWidgetLogoPhotoImporter(
        isPresented: Binding<Bool>,
        onImport: @escaping (Data) -> Void
    ) -> some View {
        modifier(BroadcastWidgetLogoPhotoImporter(isPresented: isPresented, onImport: onImport))
    }
#endif

#if os(iOS)
    func broadcastMediaPhotoImporter(
        isPresented: Binding<Bool>,
        kind: BroadcastResourceKind,
        onImport: @escaping (Data, String) -> Void
    ) -> some View {
        modifier(BroadcastMediaPhotoImporter(isPresented: isPresented, kind: kind, onImport: onImport))
    }
#endif
}
