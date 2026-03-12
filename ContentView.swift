import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @Binding var document: TextDocument
    @AppStorage(Preferences.Keys.editorTheme) private var editorThemeRaw = Preferences.Defaults.editorTheme

    @Environment(\.newDocument) private var newDocument

    private var theme: EditorTheme {
        EditorTheme(rawValue: editorThemeRaw) ?? .system
    }

    var body: some View {
        EditorView(text: $document.text, theme: theme)
            .frame(minWidth: 720, minHeight: 520)
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        newDocument(contentType: UTType.plainText)
                    } label: {
                        Label(String(localized: "New"), systemImage: "doc.badge.plus")
                    }

                    Button {
                        NSDocumentController.shared.openDocument(nil)
                    } label: {
                        Label(String(localized: "Open"), systemImage: "folder")
                    }

                    Picker(String(localized: "Theme"), selection: $editorThemeRaw) {
                        ForEach(EditorTheme.allCases) { mode in
                            Text(mode.localizedName).tag(mode.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(width: 110)
                }
            }
            .onAppear { theme.applyAppAppearance() }
            .onChange(of: editorThemeRaw) {
                theme.applyAppAppearance()
            }
    }
}
