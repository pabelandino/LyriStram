import SwiftUI

public struct DirectorLeftSidebarTabPicker: View {
    @Binding var selection: DirectorSidebarTab

    public init(selection: Binding<DirectorSidebarTab>) {
        self._selection = selection
    }

    public var body: some View {
        Picker("Panel", selection: $selection) {
            ForEach(DirectorSidebarTab.leftRailTabs) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .broadcastNativeSegmentedControl()
        .padding(.bottom, 4)
        .onAppear {
            if !DirectorSidebarTab.leftRailTabs.contains(selection) {
                selection = .cameras
            }
        }
    }
}
