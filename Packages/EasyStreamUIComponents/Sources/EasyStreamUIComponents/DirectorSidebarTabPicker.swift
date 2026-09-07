import SwiftUI

public struct DirectorSidebarTabPicker: View {
    @Binding var selection: DirectorSidebarTab

    public init(selection: Binding<DirectorSidebarTab>) {
        self._selection = selection
    }

    public var body: some View {
        Picker("Panel", selection: $selection) {
            ForEach(DirectorSidebarTab.allCases) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .broadcastNativeSegmentedControl()
        .padding(.bottom, 4)
    }
}
