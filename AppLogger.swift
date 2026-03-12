import OSLog

// MARK: - Centralized Logger
// Single source of truth for all app logging.
// OSLog is the correct Apple platform logging system:
// - Logs appear in Console.app filtered by subsystem
// - Zero overhead when log level is disabled
// - Never use print() in production code

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.simpletexteditor"

    static let document = Logger(subsystem: subsystem, category: "document")
    static let ui       = Logger(subsystem: subsystem, category: "ui")
    static let theme    = Logger(subsystem: subsystem, category: "theme")
}
