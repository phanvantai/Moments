import Foundation

protocol MediaRepositoryProtocol: Sendable {
    func saveMedia(data: Data, fileName: String) async throws -> String
    func loadMedia(filePath: String) async throws -> Data
    func deleteMedia(filePath: String) async throws
    func saveVoiceNote(data: Data, fileName: String) async throws -> String
    func loadVoiceNote(filePath: String) async throws -> Data
    func deleteVoiceNote(filePath: String) async throws
    func generateVideoThumbnail(videoPath: String) async throws -> String
}
