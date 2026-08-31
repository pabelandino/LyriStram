import Foundation

public enum PreviewMonitorLayoutMode: String, Codable, Sendable, CaseIterable, Identifiable {
    case auto
    case grid2x2
    case grid3x3
    case grid4x4
    case grid5x5
    case programPlusGrid
    case stripHorizontal

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .auto: "Automático"
        case .grid2x2: "2 × 2"
        case .grid3x3: "3 × 3"
        case .grid4x4: "4 × 4"
        case .grid5x5: "5 × 5"
        case .programPlusGrid: "Programa + grid"
        case .stripHorizontal: "Tira horizontal"
        }
    }
}

public struct PreviewMonitorRGBColor: Codable, Sendable, Equatable {
    public var red: Double
    public var green: Double
    public var blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public static let previewGreen = PreviewMonitorRGBColor(red: 0.12, green: 0.78, blue: 0.36)
    public static let programRed = PreviewMonitorRGBColor(red: 0.92, green: 0.18, blue: 0.18)
    public static let audioBlue = PreviewMonitorRGBColor(red: 0.22, green: 0.52, blue: 0.98)
    public static let black = PreviewMonitorRGBColor(red: 0, green: 0, blue: 0)
}

public struct PreviewMonitorOverlayOptions: Codable, Sendable, Equatable {
    public var showCameraName: Bool
    public var showSourceIndex: Bool
    public var showTallyBadges: Bool
    public var showConnectionStatus: Bool
    public var showAudioIndicator: Bool
    public var showSafeAreaGuides: Bool
    public var showProgramInGrid: Bool
    public var highlightProgramSource: Bool
    public var highlightPreviewSource: Bool

    public init(
        showCameraName: Bool = true,
        showSourceIndex: Bool = true,
        showTallyBadges: Bool = true,
        showConnectionStatus: Bool = true,
        showAudioIndicator: Bool = true,
        showSafeAreaGuides: Bool = false,
        showProgramInGrid: Bool = true,
        highlightProgramSource: Bool = true,
        highlightPreviewSource: Bool = true
    ) {
        self.showCameraName = showCameraName
        self.showSourceIndex = showSourceIndex
        self.showTallyBadges = showTallyBadges
        self.showConnectionStatus = showConnectionStatus
        self.showAudioIndicator = showAudioIndicator
        self.showSafeAreaGuides = showSafeAreaGuides
        self.showProgramInGrid = showProgramInGrid
        self.highlightProgramSource = highlightProgramSource
        self.highlightPreviewSource = highlightPreviewSource
    }
}

public struct PreviewMonitorAppearance: Codable, Sendable, Equatable {
    public var previewBorder: PreviewMonitorRGBColor
    public var programBorder: PreviewMonitorRGBColor
    public var audioAccent: PreviewMonitorRGBColor
    public var cellGap: Double
    public var borderWidth: Double
    public var background: PreviewMonitorRGBColor

    public init(
        previewBorder: PreviewMonitorRGBColor = .previewGreen,
        programBorder: PreviewMonitorRGBColor = .programRed,
        audioAccent: PreviewMonitorRGBColor = .audioBlue,
        cellGap: Double = 4,
        borderWidth: Double = 3,
        background: PreviewMonitorRGBColor = .black
    ) {
        self.previewBorder = previewBorder
        self.programBorder = programBorder
        self.audioAccent = audioAccent
        self.cellGap = cellGap
        self.borderWidth = borderWidth
        self.background = background
    }
}

public struct PreviewMonitorSettings: Codable, Sendable, Equatable {
    public var layoutMode: PreviewMonitorLayoutMode
    public var overlays: PreviewMonitorOverlayOptions
    public var appearance: PreviewMonitorAppearance
    public var openOnExternalDisplay: Bool
    public var autoPaginate: Bool
    public var pageIntervalSeconds: Double

    public init(
        layoutMode: PreviewMonitorLayoutMode = .auto,
        overlays: PreviewMonitorOverlayOptions = PreviewMonitorOverlayOptions(),
        appearance: PreviewMonitorAppearance = PreviewMonitorAppearance(),
        openOnExternalDisplay: Bool = true,
        autoPaginate: Bool = true,
        pageIntervalSeconds: Double = 6
    ) {
        self.layoutMode = layoutMode
        self.overlays = overlays
        self.appearance = appearance
        self.openOnExternalDisplay = openOnExternalDisplay
        self.autoPaginate = autoPaginate
        self.pageIntervalSeconds = pageIntervalSeconds
    }
}

public struct PreviewMultiviewGridSpec: Sendable, Equatable {
    public let columns: Int
    public let rows: Int
    public let pageCapacity: Int

    public init(columns: Int, rows: Int) {
        self.columns = max(1, columns)
        self.rows = max(1, rows)
        self.pageCapacity = self.columns * self.rows
    }
}

public enum PreviewMultiviewLayoutEngine {
    public static func gridSpec(for cameraCount: Int, mode: PreviewMonitorLayoutMode) -> PreviewMultiviewGridSpec {
        switch mode {
        case .auto:
            return autoGrid(for: max(1, cameraCount))
        case .grid2x2:
            return PreviewMultiviewGridSpec(columns: 2, rows: 2)
        case .grid3x3:
            return PreviewMultiviewGridSpec(columns: 3, rows: 3)
        case .grid4x4:
            return PreviewMultiviewGridSpec(columns: 4, rows: 4)
        case .grid5x5:
            return PreviewMultiviewGridSpec(columns: 5, rows: 5)
        case .programPlusGrid:
            return PreviewMultiviewGridSpec(columns: 4, rows: 3)
        case .stripHorizontal:
            let count = max(1, cameraCount)
            return PreviewMultiviewGridSpec(columns: count, rows: 1)
        }
    }

    public static func pageCount(cameraCount: Int, spec: PreviewMultiviewGridSpec, includesProgramHero: Bool) -> Int {
        let reserved = includesProgramHero ? 2 : 0
        let capacity = max(1, spec.pageCapacity - reserved)
        return max(1, Int(ceil(Double(max(1, cameraCount)) / Double(capacity))))
    }

    private static func autoGrid(for cameraCount: Int) -> PreviewMultiviewGridSpec {
        switch cameraCount {
        case 1: PreviewMultiviewGridSpec(columns: 1, rows: 1)
        case 2: PreviewMultiviewGridSpec(columns: 2, rows: 1)
        case 3...4: PreviewMultiviewGridSpec(columns: 2, rows: 2)
        case 5...6: PreviewMultiviewGridSpec(columns: 3, rows: 2)
        case 7...9: PreviewMultiviewGridSpec(columns: 3, rows: 3)
        case 10...12: PreviewMultiviewGridSpec(columns: 4, rows: 3)
        case 13...16: PreviewMultiviewGridSpec(columns: 4, rows: 4)
        default: PreviewMultiviewGridSpec(columns: 5, rows: 4)
        }
    }
}
