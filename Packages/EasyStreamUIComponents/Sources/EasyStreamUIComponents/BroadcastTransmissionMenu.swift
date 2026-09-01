import SwiftUI
import EasyStreamCore

#if os(macOS)
import AppKit

/// Toolbar menu: transmit to external display, Facebook or RTMPS.
public struct BroadcastTransmissionMenu: View {
    @Binding var programOutputSettings: ProgramOutputSettings
    let availableScreens: [ProgramOutputDisplayOption]
    let isExternalOutputLive: Bool
    let isNetworkPublishing: Bool
    let isFacebookConfigured: Bool
    let isFacebookLoading: Bool
    let facebookStatusMessage: String?
    let streamDestination: StreamDestination
    let onStartExternalOutput: () -> Void
    let onStopExternalOutput: () -> Void
    let onPrepareFacebookLive: () -> Void
    let onStartNetworkPublish: () -> Void
    let onStopNetworkPublish: () -> Void
    let onOpenStreamSettings: () -> Void

    public init(
        programOutputSettings: Binding<ProgramOutputSettings>,
        availableScreens: [ProgramOutputDisplayOption],
        isExternalOutputLive: Bool,
        isNetworkPublishing: Bool,
        isFacebookConfigured: Bool,
        isFacebookLoading: Bool,
        facebookStatusMessage: String?,
        streamDestination: StreamDestination,
        onStartExternalOutput: @escaping () -> Void,
        onStopExternalOutput: @escaping () -> Void,
        onPrepareFacebookLive: @escaping () -> Void,
        onStartNetworkPublish: @escaping () -> Void,
        onStopNetworkPublish: @escaping () -> Void,
        onOpenStreamSettings: @escaping () -> Void
    ) {
        _programOutputSettings = programOutputSettings
        self.availableScreens = availableScreens
        self.isExternalOutputLive = isExternalOutputLive
        self.isNetworkPublishing = isNetworkPublishing
        self.isFacebookConfigured = isFacebookConfigured
        self.isFacebookLoading = isFacebookLoading
        self.facebookStatusMessage = facebookStatusMessage
        self.streamDestination = streamDestination
        self.onStartExternalOutput = onStartExternalOutput
        self.onStopExternalOutput = onStopExternalOutput
        self.onPrepareFacebookLive = onPrepareFacebookLive
        self.onStartNetworkPublish = onStartNetworkPublish
        self.onStopNetworkPublish = onStopNetworkPublish
        self.onOpenStreamSettings = onOpenStreamSettings
    }

    private var isAnyOutputLive: Bool {
        isExternalOutputLive || isNetworkPublishing
    }

    public var body: some View {
        Menu {
            externalDisplaySection
            Divider()
            facebookSection
            Divider()
            networkSection
        } label: {
            Label {
                Text("Transmitir")
            } icon: {
                Image(systemName: "dot.radiowaves.up.forward")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(isAnyOutputLive ? BroadcastTheme.programRed : Color.primary)
            }
        }
        .menuStyle(.borderlessButton)
        .help("Transmitir a pantalla externa, Facebook o RTMPS")
    }

    @ViewBuilder
    private var externalDisplaySection: some View {
        Section("Pantalla externa") {
            if availableScreens.isEmpty {
                Text("No hay pantallas detectadas")
            } else {
                Picker("Pantalla", selection: $programOutputSettings.selectedScreenIndex) {
                    ForEach(availableScreens) { screen in
                        Text(screenLabel(screen)).tag(screen.id)
                    }
                }

                if isExternalOutputLive {
                    Button("Detener pantalla externa", role: .destructive, action: onStopExternalOutput)
                } else {
                    Button("Transmitir a pantalla seleccionada", action: onStartExternalOutput)
                }
            }
        }
    }

    @ViewBuilder
    private var facebookSection: some View {
        Section("Facebook Live") {
            if isFacebookConfigured {
                Button {
                    onPrepareFacebookLive()
                } label: {
                    if isFacebookLoading {
                        Label("Preparando…", systemImage: "hourglass")
                    } else {
                        Label("Preparar transmisión Facebook", systemImage: "f.circle.fill")
                    }
                }
                .disabled(isFacebookLoading)

                if isNetworkPublishing {
                    Label("Emisión RTMP activa", systemImage: "checkmark.circle.fill")
                }

                if let facebookStatusMessage, !facebookStatusMessage.isEmpty {
                    Text(facebookStatusMessage)
                        .font(.caption)
                }
            } else {
                Text("Configura Facebook en el inspector")
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var networkSection: some View {
        Section("RTMPS / Redes") {
            if isNetworkPublishing {
                Button("Detener emisión en red", role: .destructive, action: onStopNetworkPublish)
            } else {
                Button("Iniciar emisión RTMPS", action: onStartNetworkPublish)
                    .disabled(!streamDestination.isConfigured)
            }

            Button("Configurar destino…", action: onOpenStreamSettings)
        }
    }

    private func screenLabel(_ screen: ProgramOutputDisplayOption) -> String {
        let builtIn = screen.isBuiltIn ? " · Integrada" : ""
        return "\(screen.name) (\(screen.width)×\(screen.height))\(builtIn)"
    }
}
#endif
