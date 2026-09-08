import Foundation

/// Sections inside the unified director settings hub.
enum DirectorStudioSettingsTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case video
    case monitor
    case studio

    var id: String { rawValue }

    var title: String {
        switch self {
        case .video: "Calidad"
        case .monitor: "Monitor"
        case .studio: "Estudio"
        }
    }

    var systemImage: String {
        switch self {
        case .video: "dial.low"
        case .monitor: "display.2"
        case .studio: "gearshape"
        }
    }

    var subtitle: String {
        switch self {
        case .video: "Tiles, PROG y salida"
        case .monitor: "Multiview y overlays"
        case .studio: "Audio, emisión y cámaras"
        }
    }
}
