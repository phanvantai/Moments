import Testing
import Foundation
@testable import Littlemark

struct GalleryMediaResultTests {

    @Test func test_init_photo_storesCorrectly() {
        let data = Data([0x01, 0x02, 0x03])
        let result = GalleryMediaResult(data: data, type: .photo)

        #expect(result.data == data)
        #expect(result.type == .photo)
    }

    @Test func test_init_video_storesCorrectly() {
        let data = Data([0x04, 0x05, 0x06])
        let result = GalleryMediaResult(data: data, type: .video)

        #expect(result.data == data)
        #expect(result.type == .video)
    }

    @Test func test_init_emptyData_storesCorrectly() {
        let result = GalleryMediaResult(data: Data(), type: .photo)

        #expect(result.data.isEmpty)
        #expect(result.type == .photo)
    }

    @Test func test_init_largeData_storesCorrectly() {
        let data = Data(repeating: 0xFF, count: 1024 * 1024) // 1MB
        let result = GalleryMediaResult(data: data, type: .video)

        #expect(result.data.count == 1024 * 1024)
        #expect(result.type == .video)
    }
}
