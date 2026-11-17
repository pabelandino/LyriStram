import Foundation
import LvoqStreamCore

public enum DirectorSidebarTab: String, CaseIterable, Identifiable, Sendable {
    case cameras
    case library

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .cameras: BundleLocalization.string("director.sidebar.cameras")
        case .library: BundleLocalization.string("common.library")
        }
    }

    public var systemImage: String {
        switch self {
        case .cameras: "video.fill"
        case .library: "photo.on.rectangle.angled"
        }
    }

    /// Tabs shown on the left sources rail (library lives on the right rail).
    public static let leftRailTabs: [DirectorSidebarTab] = [.cameras]
}