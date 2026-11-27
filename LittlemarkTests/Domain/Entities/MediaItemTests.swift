import Testing
import Foundation
@testable import Littlemark

struct MediaItemTests {

    @Test func test_init_photo_hasCorrectValues() {
        let momentId = UUID()
        let item = MediaItem(
            momentId: momentId,
            type: .photo,
            filePath: "Media/photo.jpg",
            width: 1920,
            height: 1080
        )

        #expect(item.momentId == momentId)
        #expect(item.type == .photo)
        #expect(item.filePath == "Media/photo.jpg")
        #expect(item.thumbnailPath == nil)
        #expect(item.duration == nil)
        #expect(item.width == 1920)
        #expect(item.height == 1080)
        #expect(item.sortOrder == 0)
    }

    @Test func test_init_video_hasCorrectValues() {
        let momentId = UUID()
        let item = MediaItem(
            momentId: momentId,
            type: .video,
            filePath: "Media/video.mp4",
            thumbnailPath: "Thumbnails/thumb.jpg",
            duration: 30.0,
            width: 1920,
            height: 1080,
            sortOrder: 1
        )

        #expect(item.type == .video)
        #expect(item.thumbnailPath == "Thumbnails/thumb.jpg")
        #expect(item.duration == 30.0)
        #expect(item.sortOrder == 1)
    }

    @Test func test_equatable_sameItems_areEqual() {
        let id = UUID()
        let momentId = UUID()
        let item1 = MediaItem(id: id, momentId: momentId, type: .photo, filePath: "a.jpg", width: 100, height: 100)
        let item2 = MediaItem(id: id, momentId: momentId, type: .photo, filePath: "a.jpg", width: 100, height: 100)
        #expect(item1 == item2)
    }

    @Test func test_mediaType_rawValues_areCorrect() {
        #expect(MediaType.photo.rawValue == "photo")
        #expect(MediaType.video.rawValue == "video")
    }
}
