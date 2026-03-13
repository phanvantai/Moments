import Foundation

final class MediaRepository: MediaRepositoryProtocol, @unchecked Sendable {
    private let mediaFileService: MediaFileServiceProtocol

    init(mediaFileService: MediaFileServiceProtocol) {
        self.mediaFileService = mediaFileService
    }

    func saveMedia(data: Data, fileName: String) async throws -> String {
        try mediaFileService.saveFile(
            data: data,
            directory: MediaFileService.mediaDirectoryName,
            fileName: fileName
        )
    }

    func loadMedia(filePath: String) async throws -> Data {
        try mediaFileService.loadFile(filePath: filePath)
    }

    func deleteMedia(filePath: String) async throws {
        try mediaFileService.deleteFile(filePath: filePath)
    }

    func saveVoiceNote(data: Data, fileName: String) async throws -> String {
        try mediaFileService.saveFile(
            data: data,
            directory: MediaFileService.voiceDirectoryName,
            fileName: fileName
        )
    }

    func loadVoiceNote(filePath: String) async throws -> Data {
        try mediaFileService.loadFile(filePath: filePath)
    }

    func deleteVoiceNote(filePath: String) async throws {
        try mediaFileService.deleteFile(filePath: filePath)
    }

    func generateVideoThumbnail(videoPath: String) async throws -> String {
        try mediaFileService.generateVideoThumbnail(videoPath: videoPath)
    }
}
