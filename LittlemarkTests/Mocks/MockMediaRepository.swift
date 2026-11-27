import Foundation
@testable import Littlemark

final class MockMediaRepository: MediaRepositoryProtocol, @unchecked Sendable {
    // Call tracking
    var saveMediaCallCount = 0
    var loadMediaCallCount = 0
    var deleteMediaCallCount = 0
    var saveVoiceNoteCallCount = 0
    var loadVoiceNoteCallCount = 0
    var deleteVoiceNoteCallCount = 0
    var generateVideoThumbnailCallCount = 0
    var importMediaCallCount = 0
    var importVoiceNoteCallCount = 0

    // Captured arguments
    var lastSavedMediaFileName: String?
    var lastLoadedMediaPath: String?
    var lastDeletedMediaPath: String?
    var lastSavedVoiceFileName: String?
    var lastLoadedVoicePath: String?
    var lastDeletedVoicePath: String?
    var lastVideoThumbnailPath: String?
    var lastImportedMediaURL: URL?
    var lastImportedMediaFileName: String?
    var lastImportedVoiceURL: URL?
    var deletedMediaPaths: [String] = []
    var deletedVoicePaths: [String] = []

    // Configurable return values
    var savedFilePath = "Media/test.jpg"
    var savedVoicePath = "Voice/test.m4a"
    var thumbnailPath = "Thumbnails/thumb.jpg"
    var dataToReturn = Data()
    var errorToThrow: Error?

    func saveMedia(data: Data, fileName: String) async throws -> String {
        saveMediaCallCount += 1
        lastSavedMediaFileName = fileName
        if let error = errorToThrow { throw error }
        return savedFilePath
    }

    func loadMedia(filePath: String) async throws -> Data {
        loadMediaCallCount += 1
        lastLoadedMediaPath = filePath
        if let error = errorToThrow { throw error }
        return dataToReturn
    }

    func deleteMedia(filePath: String) async throws {
        deleteMediaCallCount += 1
        lastDeletedMediaPath = filePath
        deletedMediaPaths.append(filePath)
        if let error = errorToThrow { throw error }
    }

    func saveVoiceNote(data: Data, fileName: String) async throws -> String {
        saveVoiceNoteCallCount += 1
        lastSavedVoiceFileName = fileName
        if let error = errorToThrow { throw error }
        return savedVoicePath
    }

    func loadVoiceNote(filePath: String) async throws -> Data {
        loadVoiceNoteCallCount += 1
        lastLoadedVoicePath = filePath
        if let error = errorToThrow { throw error }
        return dataToReturn
    }

    func deleteVoiceNote(filePath: String) async throws {
        deleteVoiceNoteCallCount += 1
        lastDeletedVoicePath = filePath
        deletedVoicePaths.append(filePath)
        if let error = errorToThrow { throw error }
    }

    func importMedia(from fileURL: URL, fileName: String) async throws -> String {
        importMediaCallCount += 1
        lastImportedMediaURL = fileURL
        lastImportedMediaFileName = fileName
        if let error = errorToThrow { throw error }
        return savedFilePath
    }

    func importVoiceNote(from fileURL: URL, fileName: String) async throws -> String {
        importVoiceNoteCallCount += 1
        lastImportedVoiceURL = fileURL
        if let error = errorToThrow { throw error }
        return savedVoicePath
    }

    func generateVideoThumbnail(videoPath: String) async throws -> String {
        generateVideoThumbnailCallCount += 1
        lastVideoThumbnailPath = videoPath
        if let error = errorToThrow { throw error }
        return thumbnailPath
    }
}
