import Foundation

enum Preferences {

    enum Keys {
        static let editorTheme        = "editorTheme"
        static let preferencesVersion = "preferencesVersion"
    }

    static let currentVersion = 1

    enum Defaults {
        static let editorTheme = EditorTheme.system.rawValue
    }

    static func migrateIfNeeded() {
        let stored = UserDefaults.standard.integer(forKey: Keys.preferencesVersion)
        guard stored < currentVersion else { return }
        UserDefaults.standard.set(currentVersion, forKey: Keys.preferencesVersion)
    }
}
