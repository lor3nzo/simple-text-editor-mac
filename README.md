# SimpleTextEditor

A minimal, fast, plain text editor for macOS. Opens and saves `.txt` files. Nothing more.

Built with SwiftUI and AppKit as a learning project.

---

## Features

- Plain text editing with monospaced font
- Four themes: System, Light, Dark, Matrix
- Native macOS document model — autosave, versioning, and recovery built in
- `.txt` file association and Open With support
- Encoding support: UTF-8, UTF-16, ASCII, ISO Latin-1
- Actionable error alerts on read/write failures

---

## Requirements

- macOS 13 Ventura or later
- Xcode 15 or later

---

## Build and Run

```bash
git clone https://github.com/your-username/SimpleTextEditor.git
cd SimpleTextEditor
open SimpleTextEditor.xcodeproj
```

Then hit **Cmd+R** in Xcode to build and run.

No external dependencies. No package manager required.

---

## Project Structure

```
SimpleTextEditor/
├── SimpleTextEditorApp.swift       # App entry point, preference migration
├── ContentView.swift               # Main editor view, toolbar, theme application
├── SimpleTextEditorDocument.swift  # FileDocument model, read/write, encoding
├── EditorTheme.swift               # Theme definitions and appearance logic
├── ViewMenuCommands.swift          # View menu theme picker
├── AppLogger.swift                 # Centralized OSLog logging
├── Preferences.swift               # AppStorage keys, defaults, migration
├── SimpleTextEditorTests/
│   └── SimpleTextEditorTests.swift # Unit tests: document model, theme
└── SimpleTextEditorUITests/
    └── SimpleTextEditorUITests.swift # UI tests: launch, edit, save, theme
```

---

## Running Tests

**Cmd+U** in Xcode runs the full test suite.

- Unit tests cover document encoding, decoding, error handling, and theme logic
- UI tests cover launch, text editing, new document, theme switching, save, and close

---

## Known Limitations

- Files over ~2MB may open slowly. Optimized for typical plain text files under 500KB.
- Not signed or notarized — personal use only, not distributed.

---

## Themes

| Theme | Description |
|---|---|
| System | Follows macOS Light/Dark mode setting |
| Light | Forces light appearance |
| Dark | Forces dark appearance |
| Matrix | Black background, green text |

---

## License

MIT
