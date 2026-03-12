import SwiftUI

@main
struct SimpleTextEditorApp: App {

    init() {
        // Run preference migration before any view is loaded
        Preferences.migrateIfNeeded()
    }

    var body: some Scene {
        DocumentGroup(newDocument: TextDocument()) { file in
            ContentView(document: file.$document)
        }
        .commands {
            ViewMenuCommands()
        }
    }
}
