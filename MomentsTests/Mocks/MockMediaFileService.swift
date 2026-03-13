import Foundation
@testable import Moments

final class MockMediaFileService: MediaFileServiceProtocol, @unchecked Sendable {
    var saveFileCallCount = 0
    var loadFileCallCount = 0
    var deleteFileCallCount = 0
    var generateVideoThumbnailCallCount = 0
    var fileExistsCallCount = 0

    var lastSavedDirectory: String?
    var lastSavedFileName: String?
    var lastLoadedPath: String?
    var lastDeletedPath: String?

    var savedFilePath = "Media/test.jpg"
    var dataToReturn = Data()
    var thumbnailPath = "Thumbnails/thumb.jpg"
    var fileExistsResult = true
    var errorToThrow: Error?

    func saveFile(data: Data, directory: String, fileName: String) throws -> String {
        saveFileCallCount += 1
        lastSavedDirectory = directory
        lastSavedFileName = fileName
        if let error = errorToThrow { throw error }
        return "\(directory)/\(fileName)"
    }

    func loadFile(filePath: String) throws -> Data {
        loadFileCallCount += 1
        lastLoadedPath = filePath
        if let error = errorToThrow { throw error }
        return dataToReturn
    }

    func deleteFile(filePath: String) throws {
        deleteFileCallCount += 1
        lastDeletedPath = filePath
        if let error = errorToThrow { throw error }
    }

    func generateVideoThumbnail(videoPath: String) throws -> String {
        generateVideoThumbnailCallCount += 1
        if let error = errorToThrow { throw error }
        return thumbnailPath
    }

    func fileExists(filePath: String) -> Bool {
        fileExistsCallCount += 1
        return fileExistsResult
    }
}
