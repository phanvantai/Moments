import Testing
import UIKit
@testable import Moments

struct ThumbnailCacheTests {

    // MARK: - Cache Operations

    @Test func test_shared_returnsSameInstance() {
        let cache1 = ThumbnailCache.shared
        let cache2 = ThumbnailCache.shared

        #expect(cache1 === cache2)
    }

    @Test func test_image_nonExistentPath_returnsNil() async {
        let cache = ThumbnailCache.shared
        await cache.clearCache()

        let image = await cache.image(for: "nonexistent/path.jpg")

        #expect(image == nil)
    }

    @Test func test_setImage_thenImage_returnsCached() async {
        let cache = ThumbnailCache.shared
        await cache.clearCache()
        let testImage = UIImage(systemName: "star")!
        let path = "test/cached_\(UUID().uuidString).jpg"

        await cache.setImage(testImage, for: path)
        let result = await cache.image(for: path)

        #expect(result != nil)
    }

    @Test func test_clearCache_removesAllImages() async {
        let cache = ThumbnailCache.shared
        let testImage = UIImage(systemName: "star")!
        let path = "test/clear_\(UUID().uuidString).jpg"
        await cache.setImage(testImage, for: path)

        await cache.clearCache()
        let result = await cache.image(for: path)

        #expect(result == nil)
    }

    @Test func test_loadThumbnail_invalidPath_returnsNil() async {
        let cache = ThumbnailCache.shared
        await cache.clearCache()

        let result = await cache.loadThumbnail(for: "nonexistent/\(UUID().uuidString).jpg")

        #expect(result == nil)
    }
}
