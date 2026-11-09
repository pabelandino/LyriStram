import Foundation
import Observation

/// Latest Lyriora frame. The director client writes it; widgets and the air bus read it.
@MainActor
@Observable
public final class LyrioraAirFeed {
    public static let shared = LyrioraAirFeed()

    public var frame = LyrioraAirFrame.clear
    public var link: LyrioraAirLink = .idle

    private init() {}

    public var isOnAir: Bool {
        link == .connected && frame.active
    }

    public var statusTitle: String {
        switch link {
        case .connected where frame.active:
            "Lyriora al aire"
        case .connected:
            "Lyriora en espera"
        case .searching:
            "Buscando Lyriora"
        case .idle:
            "Lyriora detenido"
        }
    }
}
