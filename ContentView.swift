import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @Binding var document: TextDocument
    @AppStorage("editorTheme") private var editorThemeRaw = EditorTheme.system.rawValue

    @Environment(\.newDocument) private var newDocument

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
                    newDocument(contentType: UTType.plainText)
                } label: {
                    Label("New", systemImage: "doc.badge.plus")
                }

                Button {
                    NSDocumentController.shared.openDocument(nil)
                } label: {
                    Label("Open", systemImage: "folder")
                }

                Picker("", selection: $editorThemeRaw) {
                    ForEach(EditorTheme.allCases) { mode in
                        Text(mode.rawValue).tag(mode.rawValue)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: 110)
            }
        }
        .onAppear {
            theme.applyAppAppearance()
            applyEditorAppearance(for: theme)
        }
        .onChange(of: editorThemeRaw) { _ in
            theme.applyAppAppearance()
            applyEditorAppearance(for: theme)
        }
    }

    private func applyEditorAppearance(for theme: EditorTheme) {
        guard let window = NSApp.keyWindow else {
            print("[SimpleTextEditor] applyEditorAppearance: no key window available")
            return
        }
        guard let scrollView = findScrollView(in: window.contentView),
              let textView = scrollView.documentView as? NSTextView else {
            print("[SimpleTextEditor] applyEditorAppearance: could not locate NSTextView")
            return
        }

        if theme == .matrix {
            textView.insertionPointColor = NSColor(
                calibratedRed: 0.40, green: 1.0, blue: 0.55, alpha: 1.0
            )
            textView.selectedTextAttributes = [
                .backgroundColor: NSColor(
                    calibratedRed: 0.10, green: 0.35, blue: 0.10, alpha: 1.0
                ),
                .foregroundColor: NSColor(
                    calibratedRed: 0.75, green: 1.0, blue: 0.80, alpha: 1.0
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

    private func findScrollView(in view: NSView?, depth: Int = 0) -> NSScrollView? {
        guard let view, depth < 20 else { return nil }
        if let scrollView = view as? NSScrollView { return scrollView }
        for subview in view.subviews {
            if let found = findScrollView(in: subview, depth: depth + 1) {
                return found
            }
        }
        return nil
    }
}
