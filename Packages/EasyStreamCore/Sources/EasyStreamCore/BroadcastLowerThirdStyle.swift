import Foundation

public enum BroadcastLowerThirdStyle: String, Codable, CaseIterable, Sendable {
    case angular
    case titlePlate
    case guest
    case guestPlain

    public var displayName: String {
        switch self {
        case .angular: "Barras irregulares"
        case .titlePlate: "Título simple"
        case .guest: "Invitado"
        case .guestPlain: "Invitado sin foto"
        }
    }
}
