import Testing
import Foundation
@testable import Littlemark

struct MediaFileServiceTests {
    let tempDir: URL
    let mockThumbnailGenerator: MockThumbnailGenerator
    let sut: MediaFileService

    init() {
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("MediaFileServiceTests_\(UUID().uuidString)")
        mockThumbnailGenerator = MockThumbnailGenerator()
        sut = MediaFileService(
            baseDirectory: tempDir,
            thumbnailGenerator: mockThumbnailGenerator
        )
    }

    // MARK: - Save File

    @Test func test_saveFile_createsFileAndReturnsPath() throws {
        let data = "test data".data(using: .utf8)!

        let path = try sut.saveFile(data: data, directory: "Media", fileName: "test.jpg")

        #expect(path == "Media/test.jpg")
        #expect(sut.fileExists(filePath: path) == true)

        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test func test_saveFile_createsDirectoryIfNeeded() throws {
        let data = Data([0x00, 0x01])

        let path = try sut.saveFile(data: data, directory: "NewDir/SubDir", fileName: "file.bin")

        #expect(sut.fileExists(filePath: path) == true)

        try? FileManager.default.removeItem(at: tempDir)
    }

    // MARK: - Load File

    @Test func test_loadFile_existingFile_returnsData() throws {
        let originalData = "hello world".data(using: .utf8)!
        let path = try sut.saveFile(data: originalData, directory: "Media", fileName: "load_test.txt")

        let loadedData = try sut.loadFile(filePath: path)

        #expect(loadedData == originalData)

        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test func test_loadFile_nonExistingFile_throwsFileNotFound() {
        #expect(throws: MediaFileError.self) {
            try sut.loadFile(filePath: "nonexistent/file.txt")
        }
    }

    // MARK: - Delete File

    @Test func test_deleteFile_existingFile_removesFile() throws {
        let data = Data([0xFF])
        let path = try sut.saveFile(data: data, directory: "Media", fileName: "delete_test.bin")

        try sut.deleteFile(filePath: path)

        #expect(sut.fileExists(filePath: path) == false)

        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test func test_deleteFile_nonExistingFile_throwsFileNotFound() {
        #expect(throws: MediaFileError.self) {
            try sut.deleteFile(filePath: "nonexistent/file.txt")
        }
    }

    // MARK: - File Exists

    @Test func test_fileExists_existingFile_returnsTrue() throws {
        let data = Data([0x01])
        let path = try sut.saveFile(data: data, directory: "Media", fileName: "exists.bin")

        #expect(sut.fileExists(filePath: path) == true)

        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test func test_fileExists_nonExistingFile_returnsFalse() {
        #expect(sut.fileExists(filePath: "nope.txt") == false)
    }

    // MARK: - Generate Video Thumbnail

    @Test func test_generateVideoThumbnail_nonExistingFile_throwsFileNotFound() {
        #expect(throws: MediaFileError.self) {
            try sut.generateVideoThumbnail(videoPath: "nonexistent/video.mp4")
        }
    }

    @Test func test_generateVideoThumbnail_validFile_savesAndReturnsThumbnailPath() throws {
        // Create a fake video file
        let fakeVideoData = Data([0x00, 0x01, 0x02])
        let videoPath = try sut.saveFile(data: fakeVideoData, directory: "Media", fileName: "video.mp4")

        // Configure mock to return valid JPEG data
        mockThumbnailGenerator.dataToReturn = Data([0xFF, 0xD8, 0xFF, 0xE0])

        let thumbnailPath = try sut.generateVideoThumbnail(videoPath: videoPath)

        #expect(thumbnailPath.hasPrefix("Thumbnails/"))
        #expect(thumbnailPath.hasSuffix("_thumb.jpg"))
        #expect(sut.fileExists(filePath: thumbnailPath) == true)
        #expect(mockThumbnailGenerator.generateCallCount == 1)

        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test func test_generateVideoThumbnail_generatorFails_throwsError() throws {
        // Create a fake video file
        let fakeVideoData = Data([0x00])
        let videoPath = try sut.saveFile(data: fakeVideoData, directory: "Media", fileName: "bad.mp4")

        mockThumbnailGenerator.errorToThrow = MediaFileError.thumbnailGenerationFailed

        #expect(throws: MediaFileError.self) {
            try sut.generateVideoThumbnail(videoPath: videoPath)
        }

        try? FileManager.default.removeItem(at: tempDir)
    }

    // MARK: - Init

    @Test func test_init_withoutBaseDirectory_usesDocumentsDirectory() {
        let service = MediaFileService()
        #expect(service.fileExists(filePath: "nonexistent.txt") == false)
    }

    // MARK: - Static Properties

    @Test func test_directoryNames_areCorrect() {
        #expect(MediaFileService.mediaDirectoryName == "Media")
        #expect(MediaFileService.voiceDirectoryName == "Voice")
        #expect(MediaFileService.thumbnailDirectoryName == "Thumbnails")
    }
}

// MARK: - Mock Thumbnail Generator

final class MockThumbnailGenerator: ThumbnailGeneratorProtocol, @unchecked Sendable {
    var generateCallCount = 0
    var dataToReturn = Data([0xFF, 0xD8])
    var errorToThrow: Error?

    func generateThumbnailData(videoURL: URL) throws -> Data {
        generateCallCount += 1
        if let error = errorToThrow { throw error }
        return dataToReturn
    }
}
