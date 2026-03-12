import SwiftUI
import AppKit

final class FindableTextView: NSTextView, NSTextFinderClient {
    let textFinder = NSTextFinder()

    override init(frame: NSRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        textFinder.client = self
        usesFindBar = true
        isIncrementalSearchingEnabled = true
    }

    required init?(coder: NSCoder) { fatalError() }

    // Called from updateNSView once scroll view is in hierarchy
    func bindFindBar() {
        if textFinder.findBarContainer == nil {
            textFinder.findBarContainer = enclosingScrollView
        }
    }

    override func performFindPanelAction(_ sender: Any?) {
        textFinder.performAction(.showFindInterface)
    }

    override func performTextFinderAction(_ sender: Any?) {
        let tag = (sender as? NSControl)?.tag ?? 1
        textFinder.performAction(NSTextFinder.Action(rawValue: tag) ?? .showFindInterface)
    }

    override var string: String {
        get { super.string }
        set { super.string = newValue }
    }
}

struct EditorView: NSViewRepresentable {
    @Binding var text: String
    var theme: EditorTheme

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: EditorView
        init(_ parent: EditorView) { self.parent = parent }
        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            parent.text = tv.string
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textContainer = NSTextContainer(containerSize: NSSize(width: scrollView.contentSize.width, height: .greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        let storage = NSTextStorage()
        let layout = NSLayoutManager()
        storage.addLayoutManager(layout)
        layout.addTextContainer(textContainer)

        let textView = FindableTextView(frame: .zero, textContainer: textContainer)
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.delegate = context.coordinator
        textView.string = text

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.documentView = textView

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? FindableTextView else { return }

        // Bind find bar now that scroll view is in hierarchy
        textView.bindFindBar()

        // Claim first responder if not already
        DispatchQueue.main.async {
            if textView.window?.firstResponder !== textView {
                textView.window?.makeFirstResponder(textView)
            }
        }

        applyTheme(theme, to: textView, scrollView: scrollView)
    }

    private func applyTheme(_ theme: EditorTheme, to textView: NSTextView, scrollView: NSScrollView) {
        textView.backgroundColor = NSColor(theme.backgroundColor)
        textView.textColor = NSColor(theme.textColor)
        scrollView.backgroundColor = NSColor(theme.backgroundColor)
        textView.insertionPointColor = theme == .matrix
            ? NSColor(calibratedRed: 0.40, green: 1.0, blue: 0.55, alpha: 1.0)
            : .labelColor
        textView.selectedTextAttributes = theme == .matrix
            ? [.backgroundColor: NSColor(calibratedRed: 0.10, green: 0.35, blue: 0.10, alpha: 1.0),
               .foregroundColor:  NSColor(calibratedRed: 0.75, green: 1.0, blue: 0.80, alpha: 1.0)]
            : [.backgroundColor: NSColor.selectedTextBackgroundColor,
               .foregroundColor:  NSColor.selectedTextColor]
    }
}
