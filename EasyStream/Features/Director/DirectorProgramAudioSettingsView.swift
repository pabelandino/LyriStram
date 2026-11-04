import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Program audio source, lip-sync trim, monitor output, and input meter.
struct DirectorProgramAudioSettingsView: View {
    let viewModel: DirectorSessionViewModel
    let liveVideoAvailable: Bool
    @Bindable var monitor: ProgramAudioMonitor
    @Environment(\.directorCompactChrome) private var compact

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 8 : 10) {
            signalMeter

            Text("Fuente")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            if liveVideoAvailable {
                sourceButton(
                    title: "Video al aire",
                    subtitle: "Su audio sale por la salida y por la transmisión",
                    selected: viewModel.selectedProgramAudioInput == .liveVideo
                ) {
                    viewModel.selectProgramAudio(.liveVideo)
                }
            }

            ForEach(viewModel.sources) { source in
                sourceButton(
                    title: source.displayName,
                    subtitle: source.connectionState == .connected ? "Cámara" : "Desconectada",
                    selected: viewModel.selectedProgramAudioInput == .camera(source.id)
                ) {
                    viewModel.selectProgramAudio(.camera(source.id))
                }
            }

            ForEach(monitor.localInputs) { input in
                sourceButton(
                    title: input.name,
                    subtitle: "Interfaz de audio",
                    selected: viewModel.selectedProgramAudioInput == .localDevice(input.id)
                ) {
                    viewModel.selectProgramAudio(.localDevice(input.id))
                }
            }

            if viewModel.sources.isEmpty, monitor.localInputs.isEmpty, !liveVideoAvailable {
                Text("Conecta una cámara o una interfaz para elegir el audio.")
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            latencySection
            outputSection
        }
        .onAppear { monitor.refreshDevices() }
    }

    private var signalMeter: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 15.0)) { _ in
            let level = ProgramAudioLevelBus.current()
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Señal")
                        .font(.caption.weight(.semibold))
                    Spacer(minLength: 0)
                    Text(level > 0.02 ? "Entrando" : "En silencio")
                        .font(.caption2)
                        .foregroundStyle(level > 0.02 ? BroadcastTheme.audioGold : BroadcastTheme.subtleText)
                }
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(BroadcastTheme.panelElevated)
                        Capsule()
                            .fill(level > 0.9 ? BroadcastTheme.programRed : BroadcastTheme.audioGold)
                            .frame(width: max(4, proxy.size.width * CGFloat(level)))
                    }
                }
                .frame(height: 6)
            }
        }
    }

    private var latencySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Latencia")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            Picker("Latencia", selection: $monitor.latencyMode) {
                Text("Según la imagen").tag(ProgramAudioLatencyMode.picture)
                Text("Manual").tag(ProgramAudioLatencyMode.manual)
            }
            .pickerStyle(.segmented)
            .controlSize(.small)
            .labelsHidden()

            Text(latencyCaption)
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)

            if monitor.latencyMode == .manual {
                HStack {
                    Text("\(Int(monitor.manualLatencyMs)) ms")
                        .font(.caption.monospacedDigit())
                        .frame(width: 52, alignment: .leading)
                    Slider(value: $monitor.manualLatencyMs, in: 0...800, step: 10)
                }
            }
        }
    }

    private var outputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Salida de monitoreo")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            Picker("Salida", selection: $monitor.outputChoice) {
                Text("Sistema").tag(ProgramAudioOutputChoice.system)
                Text("Altavoz").tag(ProgramAudioOutputChoice.speaker)
            }
            .pickerStyle(.segmented)
            .controlSize(.small)
            .labelsHidden()

            HStack(spacing: 8) {
                Text(monitor.outputRouteName)
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .lineLimit(2)
                Spacer(minLength: 0)
                ProgramAudioRoutePickerButton()
                    .frame(width: 32, height: 32)
            }

            Text("Los audífonos monitorean este audio. La transmisión recibe la misma señal.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var latencyCaption: String {
        let picture = Int(monitor.pictureLatencyMs.rounded())
        switch monitor.latencyMode {
        case .picture:
            if monitor.usesLocalInput {
                return "La imagen llega \(picture) ms más tarde. La interfaz se retrasa ese tiempo para no adelantarse."
            }
            return "La imagen llega con unos \(picture) ms. El audio de la cámara o del video ya viaja con su imagen."
        case .manual:
            return "Suma milisegundos a una interfaz o a la cámara si la voz se adelanta a la imagen."
        }
    }

    private func sourceButton(title: String, subtitle: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? BroadcastTheme.audioGold : BroadcastTheme.subtleText)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption.weight(.medium))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(BroadcastTheme.subtleText)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                selected ? BroadcastTheme.audioGold.opacity(0.12) : Color.clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
        }
        .buttonStyle(.plain)
    }
}
