import SwiftUI

struct ViewMenuCommands: Commands {
    @AppStorage("editorTheme") private var editorThemeRaw = EditorTheme.system.rawValue

    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Divider()

            Picker("Theme", selection: $editorThemeRaw) {
                ForEach(EditorTheme.allCases) { mode in
                    Text(mode.rawValue).tag(mode.rawValue)
                }
            }
        }
    }
}
