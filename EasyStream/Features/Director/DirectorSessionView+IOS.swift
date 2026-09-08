#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers
import EasyStreamUIComponents
import UIKit

extension DirectorSessionView {
    @ViewBuilder
    var platformDirectorBody: some View {
        sessionContent
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
                    mediaViewModel: mediaViewModel,
                    previewMonitor: previewMonitor,
                    intercomService: intercomService,
                    initialTab: studioSettingsInitialTab,
                    onOpenPreviewMonitor: openPreviewMonitor,
                    onDone: { isStudioSettingsPresented = false }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .fileImporter(
                isPresented: $mediaViewModel.isWidgetLogoImporterPresented,
                allowedContentTypes: [.png],
                allowsMultipleSelection: false
            ) { result in
                guard case .success(let urls) = result, let url = urls.first else { return }
                mediaViewModel.importWidgetLogo(from: url)
            }
            .broadcastMediaPhotoImporter(
                isPresented: $mediaViewModel.isPhotoPickerPresented,
                kind: mediaViewModel.pendingImportKind
            ) { data, ext in
                mediaViewModel.importData(data, kind: mediaViewModel.pendingImportKind, preferredExtension: ext)
            }
            .broadcastWidgetLogoPhotoImporter(
                isPresented: $mediaViewModel.isWidgetLogoPhotoPickerPresented,
                onImport: { mediaViewModel.importWidgetLogoData($0) }
            )
    }

    @ViewBuilder
    var platformSwitcherLayout: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            directorWorkspaceLayout
        } else {
            compactLayout
        }
    }

    @ToolbarContentBuilder
    var platformDirectorToolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button {
                    openStudioSettings()
                } label: {
                    Label("Ajustes del estudio", systemImage: "gearshape")
                }
                Button {
                    openPreviewMonitor()
                } label: {
                    Label("Monitor", systemImage: "display.2")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }

    func platformDirectorSessionDidAppear() {}

    func platformPrewarmStudioSettingsWindowIfNeeded() {}

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
        previewMonitor.restartPaginationIfNeeded()
    }

    func openProgramOutput() {}
}
#endif
