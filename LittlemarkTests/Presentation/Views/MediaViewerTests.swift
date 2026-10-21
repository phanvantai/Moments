import Testing
import Foundation
@testable import Littlemark

@MainActor
struct MediaViewerTests {

    @Test func test_viewCreation_singleMedia_noPagerDots() {
        let mediaItem = MockMomentFactory.makePhotoMediaItem()
        let vm = MediaViewerViewModel(mediaItems: [mediaItem])
        let viewer = MediaViewer(viewModel: vm)

        #expect(viewer.viewModel.showPagerDots == false)
    }

    @Test func test_viewCreation_multipleMedia_showsPagerDots() {
        let photo = MockMomentFactory.makePhotoMediaItem()
        let video = MockMomentFactory.makeVideoMediaItem()
        let vm = MediaViewerViewModel(mediaItems: [photo, video])
        let viewer = MediaViewer(viewModel: vm)

        #expect(viewer.viewModel.showPagerDots == true)
    }

    @Test func test_viewCreation_emptyMedia_noPagerDots() {
        let vm = MediaViewerViewModel(mediaItems: [])
        let viewer = MediaViewer(viewModel: vm)

        #expect(viewer.viewModel.showPagerDots == false)
    }

    @Test func test_viewCreation_pageCount_matchesItems() {
        let photo = MockMomentFactory.makePhotoMediaItem()
        let video = MockMomentFactory.makeVideoMediaItem()
        let vm = MediaViewerViewModel(mediaItems: [photo, video])
        let viewer = MediaViewer(viewModel: vm)

        #expect(viewer.viewModel.pageCount == 2)
    }
}
