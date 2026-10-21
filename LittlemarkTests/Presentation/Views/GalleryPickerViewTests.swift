import Testing
import Foundation
@testable import Littlemark

struct GalleryPickerViewTests {

    // MARK: - GalleryMediaResult

    @Test func test_galleryMediaResult_photo_storesDataAndType() {
        let data = Data(repeating: 0xFF, count: 100)
        let result = GalleryMediaResult(data: data, type: .photo)

        #expect(result.data.count == 100)
        #expect(result.type == .photo)
    }

    @Test func test_galleryMediaResult_video_storesDataAndType() {
        let data = Data(repeating: 0x00, count: 500)
        let result = GalleryMediaResult(data: data, type: .video)

        #expect(result.data.count == 500)
        #expect(result.type == .video)
    }

    @Test func test_galleryMediaResult_emptyData_isValid() {
        let result = GalleryMediaResult(data: Data(), type: .photo)

        #expect(result.data.isEmpty)
        #expect(result.type == .photo)
    }

    @Test func test_galleryMediaResult_photoType_isNotVideo() {
        let result = GalleryMediaResult(data: Data(), type: .photo)

        #expect(result.type != .video)
    }

    @Test func test_galleryMediaResult_videoType_isNotPhoto() {
        let result = GalleryMediaResult(data: Data(), type: .video)

        #expect(result.type != .photo)
    }
}
