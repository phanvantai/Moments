import Testing
import Foundation
@testable import Littlemark

struct MediaRepositoryTests {
    let mockService = MockMediaFileService()

    var sut: MediaRepository {
        MediaRepository(mediaFileService: mockService)
    }

    // MARK: - Save Media

    @Test func test_saveMedia_callsServiceWithMediaDirectory() async throws {
        let data = Data([0x01])

        let path = try await sut.saveMedia(data: data, fileName: "photo.jpg")

        #expect(mockService.saveFileCallCount == 1)
        #expect(mockService.lastSavedDirectory == "Media")
        #expect(mockService.lastSavedFileName == "photo.jpg")
        #expect(path == "Media/photo.jpg")
    }

    // MARK: - Import Media

    @Test func test_importMedia_callsServiceWithMediaDirectory() async throws {
        let url = URL(fileURLWithPath: "/tmp/clip.mov")

        let path = try await sut.importMedia(from: url, fileName: "video.mov")

        #expect(mockService.importFileCallCount == 1)
        #expect(mockService.lastImportedURL == url)
        #expect(mockService.lastImportedDirectory == "Media")
        #expect(path == "Media/video.mov")
    }

    @Test func test_importVoiceNote_callsServiceWithVoiceDirectory() async throws {
        let url = URL(fileURLWithPath: "/tmp/recording.m4a")

        let path = try await sut.importVoiceNote(from: url, fileName: "note.m4a")

        #expect(mockService.importFileCallCount == 1)
        #expect(mockService.lastImportedDirectory == "Voice")
        #expect(path == "Voice/note.m4a")
    }

    // MARK: - Load Media

    @Test func test_loadMedia_callsServiceWithPath() async throws {
        mockService.dataToReturn = Data([0xFF])

        let data = try await sut.loadMedia(filePath: "Media/photo.jpg")

        #expect(mockService.loadFileCallCount == 1)
        #expect(mockService.lastLoadedPath == "Media/photo.jpg")
        #expect(data == Data([0xFF]))
    }

    // MARK: - Delete Media

    @Test func test_deleteMedia_callsServiceWithPath() async throws {
        try await sut.deleteMedia(filePath: "Media/photo.jpg")

        #expect(mockService.deleteFileCallCount == 1)
        #expect(mockService.lastDeletedPath == "Media/photo.jpg")
    }

    // MARK: - Save Voice Note

    @Test func test_saveVoiceNote_callsServiceWithVoiceDirectory() async throws {
        let data = Data([0x02])

        let path = try await sut.saveVoiceNote(data: data, fileName: "note.m4a")

        #expect(mockService.saveFileCallCount == 1)
        #expect(mockService.lastSavedDirectory == "Voice")
        #expect(mockService.lastSavedFileName == "note.m4a")
        #expect(path == "Voice/note.m4a")
    }

    // MARK: - Load Voice Note

    @Test func test_loadVoiceNote_callsServiceWithPath() async throws {
        mockService.dataToReturn = Data([0xAA])

        let data = try await sut.loadVoiceNote(filePath: "Voice/note.m4a")

        #expect(mockService.loadFileCallCount == 1)
        #expect(data == Data([0xAA]))
    }

    // MARK: - Delete Voice Note

    @Test func test_deleteVoiceNote_callsServiceWithPath() async throws {
        try await sut.deleteVoiceNote(filePath: "Voice/note.m4a")

        #expect(mockService.deleteFileCallCount == 1)
        #expect(mockService.lastDeletedPath == "Voice/note.m4a")
    }

    // MARK: - Generate Video Thumbnail

    @Test func test_generateVideoThumbnail_callsService() async throws {
        let path = try await sut.generateVideoThumbnail(videoPath: "Media/video.mp4")

        #expect(mockService.generateVideoThumbnailCallCount == 1)
        #expect(path == "Thumbnails/thumb.jpg")
    }

    // MARK: - Error Propagation

    @Test func test_saveMedia_serviceThrows_propagatesError() async {
        mockService.errorToThrow = MediaFileError.fileNotFound("test")

        await #expect(throws: MediaFileError.self) {
            try await sut.saveMedia(data: Data(), fileName: "file.jpg")
        }
    }
}
