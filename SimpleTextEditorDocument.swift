import SwiftUI
import UniformTypeIdentifiers

// Typed errors surface actionable messages to the user via macOS alert dialogs
enum DocumentError: LocalizedError {
    case unreadableFile
    case decodingFailed(encoding: String)
    case encodingFailed
    case emptyFileContents

    var errorDescription: String? {
        switch self {
        case .unreadableFile:
            return "The file could not be read. It may be damaged, missing, or inaccessible."
        case .decodingFailed(let encoding):
            return "The file could not be decoded as \(encoding). It may use an unsupported encoding or be corrupted."
        case .encodingFailed:
            return "The document could not be saved because the text could not be encoded. Your previous file has not been modified."
        case .emptyFileContents:
            return "The file appears to be empty or contains no readable content."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unreadableFile:
            return "Check that the file exists and you have permission to open it."
        case .decodingFailed:
            return "Try opening the file in another application to verify its contents."
        case .encodingFailed:
            return "Try saving again. If the problem persists, copy your text and create a new document."
        case .emptyFileContents:
            return "If the file should contain content, it may be corrupted."
        }
    }
}

struct TextDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        // Guard: file must have accessible contents
        guard let data = configuration.file.regularFileContents else {
            throw DocumentError.unreadableFile
        }

        // Try encodings in order of preference
        // UTF-8 first (most common), then UTF-16 (common on Windows/older macOS),
        // then ASCII as a safe fallback for plain text
        let encodingAttempts: [(String.Encoding, String)] = [
            (.utf8,    "UTF-8"),
            (.utf16,   "UTF-16"),
            (.ascii,   "ASCII"),
            (.isoLatin1, "ISO Latin-1")
        ]

        for (encoding, label) in encodingAttempts {
            if let string = String(data: data, encoding: encoding) {
                self.text = string
                return
            }
            print("[SimpleTextEditor] Read: \(label) decoding failed, trying next encoding")
        }

        // All encodings exhausted — never silently fall back to empty string
        throw DocumentError.decodingFailed(encoding: "any supported encoding (UTF-8, UTF-16, ASCII, Latin-1)")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // Guard: never silently write empty data on encoding failure
        guard let data = text.data(using: .utf8) else {
            throw DocumentError.encodingFailed
        }

        // Guard: surface suspiciously empty writes (protects against accidental data loss)
        // Allow intentional empty documents but log for observability
        if data.isEmpty && !text.isEmpty {
            throw DocumentError.encodingFailed
        }

        if text.isEmpty {
            print("[SimpleTextEditor] Write: saving empty document (intentional)")
        }

        return FileWrapper(regularFileWithContents: data)
    }
}
