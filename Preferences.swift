import Foundation

// MARK: - Centralized Preferences
// Single source of truth for all AppStorage keys.
// Versioned to support future migration without silent data loss.
// To migrate: bump currentVersion, add a migration block in migrateIfNeeded().

enum Preferences {

    // MARK: Keys
    enum Keys {
        static let editorTheme       = "editorTheme"
        static let preferencesVersion = "preferencesVersion"
    }

    // MARK: Version
    static let currentVersion = 1

    // MARK: Defaults
    enum Defaults {
        static let editorTheme = EditorTheme.system.rawValue
    }

    // MARK: Migration
    static func migrateIfNeeded() {
        let stored = UserDefaults.standard.integer(forKey: Keys.preferencesVersion)
        guard stored < currentVersion else { return }

        // Version 1: initial release, no migration needed
        // Future: add cases here as new versions are introduced
        // Example:
        // if stored < 2 {
        //     // migrate from v1 to v2
        // }

        UserDefaults.standard.set(currentVersion, forKey: Keys.preferencesVersion)
    }
}
