import Foundation

enum DirectorStudioSettingsTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case video
    case monitor
    case studio

    var id: String { rawValue }

    var title: String {
        switch self {
        case .video: L10n.StudioTab.qualityTitle
        case .monitor: L10n.StudioTab.monitorTitle
        case .studio: L10n.StudioTab.studioTitle
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
        case .video: L10n.StudioTab.qualitySubtitle
        case .monitor: L10n.StudioTab.monitorSubtitle
        case .studio: L10n.StudioTab.studioSubtitle
        }
    }
}