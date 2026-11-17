#if os(iOS)
import SwiftUI
import LvoqStreamCore
import LvoqStreamUIComponents

struct DirectorStudioSettingsHubIOSLayout<DetailContent: View>: View {
    @Binding var selectedTab: DirectorStudioSettingsTab
    let horizontalSizeClass: UserInterfaceSizeClass?
    @ViewBuilder let detailContent: (DirectorStudioSettingsTab) -> DetailContent

    var body: some View {
        if horizontalSizeClass == .compact {
            compactPhoneLayout
        } else {
            iPadSplitLayout
        }
    }

    private var compactPhoneLayout: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker(BundleLocalization.string("common.section"), selection: $selectedTab) {
                    ForEach(DirectorStudioSettingsTab.allCases) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

                DirectorStudioSettingsDeferredDetail {
                    detailContent(selectedTab)
                }
            }
            .navigationTitle(L10n.Common.settings)
        }
    }

    private var iPadSplitLayout: some View {
        NavigationSplitView {
            iPadSidebar
        } detail: {
            DirectorStudioSettingsDeferredDetail {
                detailContent(selectedTab)
                    .navigationTitle(selectedTab.title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(BroadcastTheme.panelBackground)
            }
        }
    }

    private var iPadSidebar: some View {
        List {
            ForEach(DirectorStudioSettingsTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    DirectorStudioSettingsSidebarLabel(tab: tab)
                }
                .buttonStyle(.plain)
                .listRowBackground(
                    selectedTab == tab
                        ? Color.accentColor.opacity(0.15)
                        : Color.clear
                )
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(L10n.Common.settings)
    }
}

extension View {
    @ViewBuilder
    func directorStudioSettingsHubWindowSizing() -> some View {
        self
    }
}
#endif
