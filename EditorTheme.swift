import SwiftUI
import AppKit

enum EditorTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case matrix = "Matrix"

    var id: String { rawValue }

    var textColor: Color {
        switch self {
        case .matrix:
            return Color(nsColor: NSColor(calibratedRed: 0.22, green: 1.0, blue: 0.38, alpha: 1.0))
        default:
            return Color.primary
        }
    }

    var backgroundColor: Color {
        switch self {
        case .matrix:
            return Color(nsColor: NSColor(calibratedRed: 0.0, green: 0.03, blue: 0.0, alpha: 1.0))
        default:
            return Color(NSColor.textBackgroundColor)
        }
    }

    func applyAppAppearance() {
        switch self {
        case .system:
            NSApp.appearance = nil
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark, .matrix:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}
