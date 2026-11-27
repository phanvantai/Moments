import Testing
import Foundation
@testable import Littlemark

@MainActor
struct MediaViewerViewModelTests {

    @Test func test_showPagerDots_singleItem_returnsFalse() {
        let vm = MediaViewerViewModel(mediaItems: [MockMomentFactory.makePhotoMediaItem()])

        #expect(vm.showPagerDots == false)
    }

    @Test func test_showPagerDots_multipleItems_returnsTrue() {
        let items = [MockMomentFactory.makePhotoMediaItem(), MockMomentFactory.makeVideoMediaItem()]
        let vm = MediaViewerViewModel(mediaItems: items)

        #expect(vm.showPagerDots == true)
    }

    @Test func test_showPagerDots_empty_returnsFalse() {
        let vm = MediaViewerViewModel(mediaItems: [])

        #expect(vm.showPagerDots == false)
    }

    @Test func test_pageCount_matchesItemCount() {
        let items = [MockMomentFactory.makePhotoMediaItem(), MockMomentFactory.makeVideoMediaItem()]
        let vm = MediaViewerViewModel(mediaItems: items)

        #expect(vm.pageCount == 2)
    }

    @Test func test_currentPage_defaultsToZero() {
        let vm = MediaViewerViewModel(mediaItems: [MockMomentFactory.makePhotoMediaItem()])

        #expect(vm.currentPage == 0)
    }

    @Test func test_currentPage_canBeChanged() {
        let items = [MockMomentFactory.makePhotoMediaItem(), MockMomentFactory.makeVideoMediaItem()]
        let vm = MediaViewerViewModel(mediaItems: items)

        vm.currentPage = 1

        #expect(vm.currentPage == 1)
    }

    @Test func test_mediaItem_validIndex_returnsItem() {
        let item = MockMomentFactory.makePhotoMediaItem()
        let vm = MediaViewerViewModel(mediaItems: [item])

        #expect(vm.mediaItem(at: 0) == item)
    }

    @Test func test_mediaItem_invalidIndex_returnsNil() {
        let vm = MediaViewerViewModel(mediaItems: [MockMomentFactory.makePhotoMediaItem()])

        #expect(vm.mediaItem(at: 5) == nil)
    }

    @Test func test_mediaItem_negativeIndex_returnsNil() {
        let vm = MediaViewerViewModel(mediaItems: [MockMomentFactory.makePhotoMediaItem()])

        #expect(vm.mediaItem(at: -1) == nil)
    }

    @Test func test_mediaFileURL_returnsValidURL() {
        let item = MockMomentFactory.makePhotoMediaItem()
        let vm = MediaViewerViewModel(mediaItems: [item])
        let url = vm.mediaFileURL(for: item)

        #expect(url.lastPathComponent.contains("photo"))
    }
}
