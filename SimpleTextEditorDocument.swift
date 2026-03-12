import SwiftUI
import UniformTypeIdentifiers

enum DocumentError: LocalizedError {
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "The document could not be saved because the text could not be encoded. Your previous file has not been modified."
        case .decodingFailed:
            return "The file could not be opened because it contains unreadable content."
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
        guard let data = configuration.file.regularFileContents else {
            throw DocumentError.decodingFailed
        }
        guard let string = String(data: data, encoding: .utf8) else {
            throw DocumentError.decodingFailed
        }
        self.text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = text.data(using: .utf8) else {
            throw DocumentError.encodingFailed
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
