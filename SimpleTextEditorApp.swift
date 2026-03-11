import SwiftUI

@main
struct SimpleTextEditorApp: App {
    @AppStorage("editorTheme") private var editorThemeRaw = EditorTheme.system.rawValue

    var body: some Scene {
        DocumentGroup(newDocument: TextDocument()) { file in
            ContentView(document: file.$document)
                .onAppear {
                    currentTheme.applyAppAppearance()
                }
                .onChange(of: editorThemeRaw) { _ in
                    currentTheme.applyAppAppearance()
                }
        }
        .commands {
            ViewMenuCommands()
        }
    }

    private var currentTheme: EditorTheme {
        EditorTheme(rawValue: editorThemeRaw) ?? .system
    }
}
