import SwiftUI
import UniformTypeIdentifiers
import OSLog

// MARK: - Document Errors
// LocalizedError conformance means macOS surfaces these automatically
// as actionable alert dialogs — no custom alert code needed.

enum DocumentError: LocalizedError {
    case unreadableFile
    case decodingFailed(encoding: String)
    case encodingFailed
    case emptyFileContents

    var errorDescription: String? {
        switch self {
        case .unreadableFile:
            return String(localized: "The file could not be read. It may be damaged, missing, or inaccessible.")
        case .decodingFailed(let encoding):
            return String(localized: "The file could not be decoded as \(encoding). It may use an unsupported encoding or be corrupted.")
        case .encodingFailed:
            return String(localized: "The document could not be saved because the text could not be encoded. Your previous file has not been modified.")
        case .emptyFileContents:
            return String(localized: "The file appears to be empty or contains no readable content.")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unreadableFile:
            return String(localized: "Check that the file exists and you have permission to open it.")
        case .decodingFailed:
            return String(localized: "Try opening the file in another application to verify its contents.")
        case .encodingFailed:
            return String(localized: "Try saving again. If the problem persists, copy your text and create a new document.")
        case .emptyFileContents:
            return String(localized: "If the file should contain content, it may be corrupted.")
        }
    }

    var failureReason: String? {
        switch self {
        case .unreadableFile:
            return String(localized: "The file data could not be accessed.")
        case .decodingFailed(let encoding):
            return String(localized: "No supported decoder could interpret the file as \(encoding).")
        case .encodingFailed:
            return String(localized: "The text could not be converted to UTF-8 data.")
        case .emptyFileContents:
            return String(localized: "The file wrapper contained no data.")
        }
    }
}

// MARK: - TextDocument

struct TextDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            Logger.document.error("Read failed: file has no accessible contents")
            throw DocumentError.unreadableFile
        }

        let encodingAttempts: [(String.Encoding, String)] = [
            (.utf8,      "UTF-8"),
            (.utf16,     "UTF-16"),
            (.ascii,     "ASCII"),
            (.isoLatin1, "ISO Latin-1")
        ]

        for (encoding, label) in encodingAttempts {
            if let string = String(data: data, encoding: encoding) {
                Logger.document.info("Read succeeded using \(label) encoding")
                self.text = string
                return
            }
            Logger.document.warning("Read: \(label) decoding failed, trying next encoding")
        }

        Logger.document.error("Read failed: all encodings exhausted")
        throw DocumentError.decodingFailed(encoding: "any supported encoding (UTF-8, UTF-16, ASCII, Latin-1)")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = text.data(using: .utf8) else {
            Logger.document.error("Write failed: UTF-8 encoding returned nil")
            throw DocumentError.encodingFailed
        }

        if data.isEmpty && !text.isEmpty {
            Logger.document.error("Write failed: data is empty but text is not")
            throw DocumentError.encodingFailed
        }

        if text.isEmpty {
            Logger.document.info("Write: saving intentionally empty document")
        } else {
            Logger.document.info("Write succeeded: \(data.count) bytes")
        }

        return FileWrapper(regularFileWithContents: data)
    }
}
