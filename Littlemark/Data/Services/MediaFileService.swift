import Foundation

protocol MediaFileServiceProtocol: Sendable {
    func saveFile(data: Data, directory: String, fileName: String) throws -> String
    /// Moves (or copies, when it can't be moved) a file on disk into `directory`,
    /// without loading it into memory. Use for videos and recordings.
    func importFile(from sourceURL: URL, directory: String, fileName: String) throws -> String
    func loadFile(filePath: String) throws -> Data
    func deleteFile(filePath: String) throws
    func generateVideoThumbnail(videoPath: String) throws -> String
    func fileExists(filePath: String) -> Bool
}

protocol ThumbnailGeneratorProtocol: Sendable {
    func generateThumbnailData(videoURL: URL) throws -> Data
}

final class MediaFileService: MediaFileServiceProtocol, @unchecked Sendable {
    private let baseDirectory: URL
    private let fileManager: FileManager
    private let thumbnailGenerator: ThumbnailGeneratorProtocol

    static let mediaDirectoryName = "Media"
    static let voiceDirectoryName = "Voice"
    static let thumbnailDirectoryName = "Thumbnails"

    init(
        baseDirectory: URL? = nil,
        fileManager: FileManager = .default,
        thumbnailGenerator: ThumbnailGeneratorProtocol = AVThumbnailGenerator()
    ) {
        if let baseDirectory {
            self.baseDirectory = baseDirectory
        } else {
            self.baseDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        self.fileManager = fileManager
        self.thumbnailGenerator = thumbnailGenerator
    }

    func saveFile(data: Data, directory: String, fileName: String) throws -> String {
        let directoryURL = baseDirectory.appendingPathComponent(directory)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let fileURL = directoryURL.appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return "\(directory)/\(fileName)"
    }

    func importFile(from sourceURL: URL, directory: String, fileName: String) throws -> String {
        let directoryURL = baseDirectory.appendingPathComponent(directory)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let fileURL = directoryURL.appendingPathComponent(fileName)
        do {
            try fileManager.moveItem(at: sourceURL, to: fileURL)
        } catch {
            try fileManager.copyItem(at: sourceURL, to: fileURL)
        }
        return "\(directory)/\(fileName)"
    }

    func loadFile(filePath: String) throws -> Data {
        let fileURL = baseDirectory.appendingPathComponent(filePath)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw MediaFileError.fileNotFound(filePath)
        }
        return try Data(contentsOf: fileURL)
    }

    func deleteFile(filePath: String) throws {
        let fileURL = baseDirectory.appendingPathComponent(filePath)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw MediaFileError.fileNotFound(filePath)
        }
        try fileManager.removeItem(at: fileURL)
    }

    func generateVideoThumbnail(videoPath: String) throws -> String {
        let videoURL = baseDirectory.appendingPathComponent(videoPath)
        guard fileManager.fileExists(atPath: videoURL.path) else {
            throw MediaFileError.fileNotFound(videoPath)
        }

        let jpegData = try thumbnailGenerator.generateThumbnailData(videoURL: videoURL)
        let thumbnailFileName = UUID().uuidString + "_thumb.jpg"
        return try saveFile(
            data: jpegData,
            directory: Self.thumbnailDirectoryName,
            fileName: thumbnailFileName
        )
    }

    func fileExists(filePath: String) -> Bool {
        let fileURL = baseDirectory.appendingPathComponent(filePath)
        return fileManager.fileExists(atPath: fileURL.path)
    }
}

enum MediaFileError: Error, Equatable {
    case fileNotFound(String)
    case thumbnailGenerationFailed
}
