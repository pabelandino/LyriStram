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
                        ForEach(availableScreens.filter { !$0.isBuiltIn }) { screen in
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

#elseif os(iOS)
import UIKit

public enum ProgramOutputDisplayDiscovery {
    public static func availableScreens() -> [ProgramOutputDisplayOption] {
        connectedScreens().enumerated().map { index, screen in
            let bounds = screen.bounds
            let scale = screen.scale
            let builtIn = !externalDisplayScreens().contains(screen)
            let name = builtIn ? "Pantalla integrada" : "Pantalla externa"
            return ProgramOutputDisplayOption(
                id: index,
                name: name,
                width: Int(bounds.width * scale),
                height: Int(bounds.height * scale),
                isBuiltIn: builtIn
            )
        }
    }

    public static var hasExternalDisplay: Bool {
        !externalDisplayScreens().isEmpty
    }

    public static var isExternalDisplayMirroring: Bool {
        guard let external = externalDisplayScreens().first else { return false }
        return external.mirrored != nil
    }

    public static func preferredExternalScreenIndex() -> Int? {
        let screens = connectedScreens()
        let externals = externalDisplayScreens()
        return screens.firstIndex { externals.contains($0) }
    }

    public static func preferredExternalUIScreen() -> UIScreen? {
        externalDisplayScreens().first
    }

    public static func validatedExternalScreenIndex(_ index: Int) -> Int? {
        guard hasExternalDisplay else { return nil }
        let screens = connectedScreens()
        let externals = externalDisplayScreens()
        if index >= 0, index < screens.count, externals.contains(screens[index]) {
            return index
        }
        return preferredExternalScreenIndex()
    }

    /// The screen of the foreground window scene. iPhone Duo moves this scene between displays when it folds.
    private static func activeSceneScreen() -> UIScreen? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let foreground = scenes.first { $0.activationState == .foregroundActive }
            ?? scenes.first { $0.session.role == .windowApplication }
            ?? scenes.first
        return foreground?.screen
    }

    /// HDMI and AirPlay only. The other face of an iPhone Duo is not an external program display.
    private static func externalDisplayScreens() -> [UIScreen] {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { scene in
                let role = scene.session.role
                return role == .windowExternalDisplay || role == .windowExternalDisplayNonInteractive
            }
            .map { $0.screen }
    }

    private static func connectedScreens() -> [UIScreen] {
        var screens: [UIScreen] = []
        if let active = activeSceneScreen() {
            screens.append(active)
        }
        for screen in externalDisplayScreens() where !screens.contains(screen) {
            screens.append(screen)
        }
        return screens
    }
}
#endif
