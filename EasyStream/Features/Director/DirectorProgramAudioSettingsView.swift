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

            Text("Entrada")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            Picker("Entrada", selection: sourceSelection) {
                Text("Sin fuente").tag("")
                if liveVideoAvailable {
                    Text("Video al aire").tag("video")
                }
                ForEach(viewModel.sources) { source in
                    Text(source.displayName).tag("camera:\(source.id.rawValue.uuidString)")
                }
                ForEach(monitor.localInputs) { input in
                    Text(input.name).tag("device:\(input.id)")
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()

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
            Text("Salida")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

#if os(macOS)
            Picker("Salida", selection: outputSelection) {
                Text("Sistema").tag("")
                ForEach(monitor.outputDevices) { device in
                    Text(device.name).tag(device.id)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
#else
            Picker("Salida", selection: $monitor.outputChoice) {
                Text("Sistema").tag(ProgramAudioOutputChoice.system)
                Text("Altavoz").tag(ProgramAudioOutputChoice.speaker)
            }
            .pickerStyle(.menu)
            .labelsHidden()

            ProgramAudioRoutePickerButton()
                .frame(width: 32, height: 32)
#endif

            Text(monitor.outputRouteName)
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
                .lineLimit(2)

            Text("Los audífonos o la interfaz monitorean este audio. La transmisión recibe la misma señal.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var sourceSelection: Binding<String> {
        Binding(
            get: {
                switch viewModel.selectedProgramAudioInput {
                case .liveVideo:
                    return "video"
                case .camera(let id):
                    return "camera:\(id.rawValue.uuidString)"
                case .localDevice(let uid):
                    return "device:\(uid)"
                case nil:
                    return ""
                }
            },
            set: { value in
                if value == "video" {
                    viewModel.selectProgramAudio(.liveVideo)
                } else if value.hasPrefix("camera:"),
                          let uuid = UUID(uuidString: String(value.dropFirst("camera:".count))) {
                    viewModel.selectProgramAudio(.camera(CameraSourceID(uuid)))
                } else if value.hasPrefix("device:") {
                    viewModel.selectProgramAudio(.localDevice(String(value.dropFirst("device:".count))))
                }
            }
        )
    }

#if os(macOS)
    private var outputSelection: Binding<String> {
        Binding(
            get: { monitor.selectedOutputUID },
            set: { monitor.selectedOutputUID = $0 }
        )
    }
#endif

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
}
