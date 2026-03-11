import SwiftUI
import AppKit

struct ContentView: View {
    @Binding var document: TextDocument
    @AppStorage("editorTheme") private var editorThemeRaw = EditorTheme.system.rawValue

    private var theme: EditorTheme {
        EditorTheme(rawValue: editorThemeRaw) ?? .system
    }

    var body: some View {
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()

            TextEditor(text: $document.text)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(theme.textColor)
                .scrollContentBackground(.hidden)
                .background(theme.backgroundColor)
                .padding(12)
        }
        .frame(minWidth: 720, minHeight: 520)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    NSDocumentController.shared.newDocument(nil)
                } label: {
                    Label("New", systemImage: "doc.badge.plus")
                }

                Button {
                    NSDocumentController.shared.openDocument(nil)
                } label: {
                    Label("Open", systemImage: "folder")
                }

                Menu {
                    Picker("Theme", selection: $editorThemeRaw) {
                        ForEach(EditorTheme.allCases) { mode in
                            Text(mode.rawValue).tag(mode.rawValue)
                        }
                    }
                } label: {
                    Text("Theme: \(theme.rawValue)")
                }
            }
        }
        .onAppear {
            theme.applyAppAppearance()
            DispatchQueue.main.async {
                applyEditorAppearance(for: theme)
            }
        }
        .onChange(of: editorThemeRaw) { _ in
            theme.applyAppAppearance()
            DispatchQueue.main.async {
                applyEditorAppearance(for: theme)
            }
        }
    }

    private func applyEditorAppearance(for theme: EditorTheme) {
        guard let window = NSApp.keyWindow,
              let scrollView = findScrollView(in: window.contentView),
              let textView = scrollView.documentView as? NSTextView else { return }

        if theme == .matrix {
            textView.insertionPointColor = NSColor(
                calibratedRed: 0.40,
                green: 1.0,
                blue: 0.55,
                alpha: 1.0
            )
            textView.selectedTextAttributes = [
                .backgroundColor: NSColor(
                    calibratedRed: 0.10,
                    green: 0.35,
                    blue: 0.10,
                    alpha: 1.0
                ),
                .foregroundColor: NSColor(
                    calibratedRed: 0.75,
                    green: 1.0,
                    blue: 0.80,
                    alpha: 1.0
                )
            ]
        } else {
            textView.insertionPointColor = .labelColor
            textView.selectedTextAttributes = [
                .backgroundColor: NSColor.selectedTextBackgroundColor,
                .foregroundColor: NSColor.selectedTextColor
            ]
        }
    }

    private func findScrollView(in view: NSView?) -> NSScrollView? {
        guard let view else { return nil }

        if let scrollView = view as? NSScrollView {
            return scrollView
        }

        for subview in view.subviews {
            if let found = findScrollView(in: subview) {
                return found
            }
        }

        return nil
    }
}
