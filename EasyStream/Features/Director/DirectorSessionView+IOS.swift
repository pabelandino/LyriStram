#if os(iOS)
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import EasyStreamCore
import EasyStreamUIComponents

extension DirectorSessionView {
    @ViewBuilder
    var platformDirectorBody: some View {
        sessionContent
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .onChange(of: horizontalSizeClass) { _, _ in
                applyInnerOrientation()
            }
            .sheet(isPresented: $isStreamSettingsPresented) {
                NavigationStack {
                    StreamDestinationPanel(
                        destination: $viewModel.streamDestination,
                        publisherStats: viewModel.publisherStats,
                        isPublishing: viewModel.isPublishing,
                        onStart: {
                            viewModel.startPublishing()
                            isStreamSettingsPresented = false
                        },
                        onStop: { viewModel.stopPublishing() }
                    )
                    .padding()
                    .navigationTitle("Destino RTMPS")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Listo") { isStreamSettingsPresented = false }
                        }
                    }
                }
            }
            .sheet(isPresented: $isStudioSettingsPresented) {
                DirectorStudioSettingsHubView(
                    viewModel: viewModel,
                    previewMonitor: previewMonitor,
                    initialTab: studioSettingsInitialTab,
                    onOpenPreviewMonitor: openPreviewMonitor,
                    onDone: { isStudioSettingsPresented = false }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .broadcastMediaPhotoImporter(
                isPresented: $mediaViewModel.isPhotoPickerPresented,
                kind: mediaViewModel.pendingImportKind
            ) { data, ext in
                mediaViewModel.importData(data, kind: mediaViewModel.pendingImportKind, preferredExtension: ext)
            }
    }

    @ViewBuilder
    var platformSwitcherLayout: some View {
        if horizontalSizeClass == .regular {
            directorWorkspaceLayout
        } else {
            compactLayout
        }
    }

    @ToolbarContentBuilder
    var platformDirectorToolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            EmptyView()
        }
    }

    func platformDirectorSessionDidAppear() {
        applyInnerOrientation()
    }

    /// Fully stretched inner Duo is landscape only. iPad director can rotate.
    private func applyInnerOrientation() {
        let phone = UIDevice.current.userInterfaceIdiom == .phone
        AppOrientationPolicy.apply(phone: phone, regularWidth: horizontalSizeClass == .regular)
    }

    func openStudioSettings(tab: DirectorStudioSettingsTab = .studio) {
        studioSettingsInitialTab = tab
        DirectorModalPresentation.afterYield {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                isStudioSettingsPresented = true
            }
        }
    }

    func openStreamSettings() {
        DirectorModalPresentation.afterYield {
            isStreamSettingsPresented = true
        }
    }

    func openPreviewMonitor() {
        let shownOnExternal = PreviewMonitorExternalDisplayController.shared.present(
            openOnExternalDisplay: previewMonitor.settings.openOnExternalDisplay
        )
        if !shownOnExternal {
            DirectorModalPresentation.afterYield {
                isPreviewMonitorPresented = true
            }
        }
        previewMonitor.restartPaginationIfNeeded()
    }

    func openProgramOutput() {}
}
#endif
