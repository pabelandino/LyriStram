import Foundation
import OSLog

public enum EasyStreamLog {
    public static let subsystem = "com.easystream"

    public static let discovery = Logger(subsystem: subsystem, category: "discovery")
    public static let transport = Logger(subsystem: subsystem, category: "transport")
    public static let capture = Logger(subsystem: subsystem, category: "capture")
    public static let encoder = Logger(subsystem: subsystem, category: "encoder")
    public static let audio = Logger(subsystem: subsystem, category: "audio")
    public static let rtmp = Logger(subsystem: subsystem, category: "rtmp")
    public static let facebook = Logger(subsystem: subsystem, category: "facebook")
    public static let app = Logger(subsystem: subsystem, category: "app")
    /// PROG frame bus: Take cuts, lane holds, compositor, camera transport ramps.
    public static let programBus = Logger(subsystem: subsystem, category: "ProgramBus")
}
