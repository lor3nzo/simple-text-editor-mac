import SwiftUI
import AppKit

struct ViewMenuCommands: Commands {
    @AppStorage(Preferences.Keys.editorTheme) private var editorThemeRaw = Preferences.Defaults.editorTheme

    var body: some Commands {
        // Explicitly add Find to Edit menu
        CommandGroup(after: .pasteboard) {
            Divider()
            Menu("Find") {
                Button("Find...") {
                    performFind(action: 1)
                }
                .keyboardShortcut("f", modifiers: .command)

                Button("Find and Replace...") {
                    performFind(action: 12)
                }
                .keyboardShortcut("f", modifiers: [.command, .option])

                Button("Find Next") {
                    performFind(action: 2)
                }
                .keyboardShortcut("g", modifiers: .command)

                Button("Find Previous") {
                    performFind(action: 3)
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
            }
            Divider()
        }

        CommandGroup(after: .toolbar) {
            Divider()
            Picker(String(localized: "Theme"), selection: $editorThemeRaw) {
                ForEach(EditorTheme.allCases) { mode in
                    Text(mode.localizedName).tag(mode.rawValue)
                }
            }
        }
    }

    private func performFind(action: Int) {
        guard let textView = NSApp.keyWindow?.firstResponder as? FindableTextView else {
            // Try to find it in the view hierarchy
            if let contentView = NSApp.keyWindow?.contentView,
               let textView = findTextView(in: contentView) {
                NSApp.keyWindow?.makeFirstResponder(textView)
                textView.textFinder.performAction(
                    NSTextFinder.Action(rawValue: action) ?? .showFindInterface)
            }
            return
        }
        textView.textFinder.performAction(
            NSTextFinder.Action(rawValue: action) ?? .showFindInterface)
    }

    private func findTextView(in view: NSView) -> FindableTextView? {
        if let tv = view as? FindableTextView { return tv }
        for sub in view.subviews {
            if let found = findTextView(in: sub) { return found }
        }
        return nil
    }
}
