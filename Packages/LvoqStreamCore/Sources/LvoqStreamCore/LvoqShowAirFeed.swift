import Foundation
import Observation

/// Latest LvoqShow frame. The director client writes it; widgets and the air bus read it.
@MainActor
@Observable
public final class LvoqShowAirFeed {
    public static let shared = LvoqShowAirFeed()

    public var frame = LvoqShowAirFrame.clear
    public var link: LvoqShowAirLink = .idle

    private init() {}

    public var isOnAir: Bool {
        link == .connected && frame.active
    }

    public var statusTitle: String {
        let key: String
        switch link {
        case .connected where frame.active:
            key = "lvoqShow.status.onAir"
        case .connected:
            key = "lvoqShow.status.standingBy"
        case .searching:
            key = "lvoqShow.status.searching"
        case .idle:
            key = "lvoqShow.status.stopped"
        }
        return String(
            localized: String.LocalizationValue(key),
            locale: AppLocalization.resolvedLocale
        )
    }
}
