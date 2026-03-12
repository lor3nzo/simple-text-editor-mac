import SwiftUI

struct ViewMenuCommands: Commands {
    @AppStorage(Preferences.Keys.editorTheme) private var editorThemeRaw = Preferences.Defaults.editorTheme

    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Divider()

            Picker(String(localized: "Theme"), selection: $editorThemeRaw) {
                ForEach(EditorTheme.allCases) { mode in
                    Text(mode.localizedName).tag(mode.rawValue)
                }
            }
        }
    }
}
