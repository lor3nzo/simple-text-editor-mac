import SwiftUI

@main
struct SimpleTextEditorApp: App {
    @AppStorage("editorTheme") private var editorThemeRaw = EditorTheme.system.rawValue

    var body: some Scene {
        DocumentGroup(newDocument: TextDocument()) { file in
            ContentView(document: file.$document)
        }
        .commands {
            ViewMenuCommands()
        }
    }
}
