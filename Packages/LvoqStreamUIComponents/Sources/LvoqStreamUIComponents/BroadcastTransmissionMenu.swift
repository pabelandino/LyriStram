import SwiftUI
import LvoqStreamCore

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

    /// Built-in display stays with the director. Output only targets another screen.
    private var externalScreens: [ProgramOutputDisplayOption] {
        availableScreens.filter { !$0.isBuiltIn }
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
                Text(BundleLocalization.string("Transmitir"))
            } icon: {
                Image(systemName: "dot.radiowaves.up.forward")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(isAnyOutputLive ? BroadcastTheme.programRed : Color.primary)
            }
        }
        .menuStyle(.borderlessButton)
        .help(BundleLocalization.string("Transmitir a pantalla externa, Facebook o RTMPS"))
    }

    @ViewBuilder
    private var externalDisplaySection: some View {
        Section(BundleLocalization.string("Pantalla externa")) {
            if externalScreens.isEmpty {
                Text(BundleLocalization.string("Conecta un monitor, TV o proyector. La pantalla del director no se usa."))
            } else {
                Picker(BundleLocalization.string("Pantalla"), selection: $programOutputSettings.selectedScreenIndex) {
                    ForEach(externalScreens) { screen in
                        Text(screenLabel(screen)).tag(screen.id)
                    }
                }

                if isExternalOutputLive {
                    Button(BundleLocalization.string("Detener pantalla externa"), role: .destructive, action: onStopExternalOutput)
                } else {
                    Button(BundleLocalization.string("Transmitir a pantalla seleccionada"), action: onStartExternalOutput)
                }
            }
        }
    }

    @ViewBuilder
    private var facebookSection: some View {
        Section(BundleLocalization.string("Facebook Live")) {
            if isFacebookConfigured {
                Button {
                    onPrepareFacebookLive()
                } label: {
                    if isFacebookLoading {
                        Label(BundleLocalization.string("stream.preparing"), systemImage: "hourglass")
                    } else {
                        Label(BundleLocalization.string("facebook.prepare_broadcast_full"), systemImage: "f.circle.fill")
                    }
                }
                .disabled(isFacebookLoading)

                if isNetworkPublishing {
                    Label(BundleLocalization.string("stream.rtmp_active"), systemImage: "checkmark.circle.fill")
                }

                if let facebookStatusMessage, !facebookStatusMessage.isEmpty {
                    Text(facebookStatusMessage)
                        .font(.caption)
                }
            } else {
                Text(BundleLocalization.string("Configura Facebook en el inspector"))
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var networkSection: some View {
        Section(BundleLocalization.string("RTMPS / Redes")) {
            if isNetworkPublishing {
                Button(BundleLocalization.string("Detener emisión en red"), role: .destructive, action: onStopNetworkPublish)
            } else {
                Button(BundleLocalization.string("Iniciar emisión RTMPS"), action: onStartNetworkPublish)
                    .disabled(!streamDestination.isConfigured)
            }

            Button(BundleLocalization.string("Configurar destino…"), action: onOpenStreamSettings)
        }
    }

    private func screenLabel(_ screen: ProgramOutputDisplayOption) -> String {
        let builtIn = screen.isBuiltIn ? " · Integrada" : ""
        return "\(screen.name) (\(screen.width)×\(screen.height))\(builtIn)"
    }
}
#endif
