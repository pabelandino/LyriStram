#if os(macOS)
import SwiftUI
import EasyStreamUIComponents

struct DirectorStudioSettingsHubMacLayout<DetailContent: View>: View {
    @Binding var selectedTab: DirectorStudioSettingsTab
    @ViewBuilder let detailContent: (DirectorStudioSettingsTab) -> DetailContent

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            DirectorStudioSettingsDeferredDetail {
                detailContent(selectedTab)
                    .navigationTitle(selectedTab.title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(BroadcastTheme.panelBackground)
            }
        }
        .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 260)
    }

    private var sidebar: some View {
        List(selection: $selectedTab) {
            ForEach(DirectorStudioSettingsTab.allCases) { tab in
                DirectorStudioSettingsSidebarLabel(tab: tab)
                    .tag(tab)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Ajustes")
    }
}

extension View {
    @ViewBuilder
    func directorStudioSettingsHubWindowSizing() -> some View {
        frame(minWidth: 720, minHeight: 640)
    }
}
#endif
