import SwiftUI
import EasyStreamCore

public struct ProgramOutputDestinationPanel: View {
    @Binding var settings: ProgramOutputSettings
    let availableScreens: [ProgramOutputDisplayOption]
    let isOutputWindowOpen: Bool
    let onOpenOutput: () -> Void
    let onMoveToSelectedScreen: () -> Void

    public init(
        settings: Binding<ProgramOutputSettings>,
        availableScreens: [ProgramOutputDisplayOption],
        isOutputWindowOpen: Bool,
        onOpenOutput: @escaping () -> Void,
        onMoveToSelectedScreen: @escaping () -> Void
    ) {
        _settings = settings
        self.availableScreens = availableScreens
        self.isOutputWindowOpen = isOutputWindowOpen
        self.onOpenOutput = onOpenOutput
        self.onMoveToSelectedScreen = onMoveToSelectedScreen
    }

    private var hasExternalDisplay: Bool {
        availableScreens.count > 1
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alternativa a Facebook/RTMP: envía el programa limpio a una pantalla externa (TV, proyector, capturadora).")
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)

            Toggle("Salida a pantalla externa", isOn: $settings.isEnabled)
                .toggleStyle(.switch)
                .disabled(!hasExternalDisplay)

            if !hasExternalDisplay {
                Text("Conecta un monitor externo para habilitar la salida de programa.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if settings.isEnabled {
                if availableScreens.isEmpty {
                    Text("No se detectaron pantallas.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Pantalla destino", selection: $settings.selectedScreenIndex) {
                        ForEach(availableScreens) { screen in
                            Text("\(screen.name) · \(screen.width)×\(screen.height)")
                                .tag(screen.id)
                        }
                    }

                    Toggle("Pantalla completa en destino", isOn: $settings.fillScreen)
                        .toggleStyle(.switch)
                }

                Button(action: onOpenOutput) {
                    Label(
                        isOutputWindowOpen ? "Ventana de programa abierta" : "Abrir ventana de programa",
                        systemImage: "tv"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.liveAmber, isProminent: true))

                if isOutputWindowOpen {
                    Button(action: onMoveToSelectedScreen) {
                        Label("Mover a pantalla seleccionada", systemImage: "display")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BroadcastGlassBorderedButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if os(macOS)
import AppKit

public enum ProgramOutputDisplayDiscovery {
    public static func availableScreens() -> [ProgramOutputDisplayOption] {
        NSScreen.screens.enumerated().map { index, screen in
            let frame = screen.frame
            let builtIn = screen == NSScreen.main
            return ProgramOutputDisplayOption(
                id: index,
                name: screen.localizedName.isEmpty ? "Pantalla \(index + 1)" : screen.localizedName,
                width: Int(frame.width),
                height: Int(frame.height),
                isBuiltIn: builtIn
            )
        }
    }

    public static func screen(for index: Int) -> NSScreen? {
        let screens = NSScreen.screens
        guard !screens.isEmpty else { return nil }
        let clamped = min(max(0, index), screens.count - 1)
        return screens[clamped]
    }

    public static var hasExternalDisplay: Bool {
        NSScreen.screens.count > 1
    }

    /// Returns the index of the first non-built-in screen, or nil when only one display is connected.
    public static func preferredExternalScreenIndex() -> Int? {
        let screens = NSScreen.screens
        guard screens.count > 1 else { return nil }
        if let external = screens.enumerated().first(where: { $0.element != NSScreen.main }) {
            return external.offset
        }
        return nil
    }

    /// Validates a stored screen index for external program output.
    public static func validatedExternalScreenIndex(_ index: Int) -> Int? {
        guard hasExternalDisplay else { return nil }
        let screens = NSScreen.screens
        if index >= 0, index < screens.count, screens[index] != NSScreen.main {
            return index
        }
        return preferredExternalScreenIndex()
    }
}
#endif
