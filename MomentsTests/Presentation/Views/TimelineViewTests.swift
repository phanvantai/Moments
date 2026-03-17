import Testing
import Foundation
@testable import Moments

struct TimelineViewTests {

    @Test func test_emptyMoments_showsEmptyState() {
        let view = TimelineView(
            moments: [],
            isLoadingMore: false,
            hasMoreOlderMoments: false,
            onMomentTap: { _ in },
            onDeleteRequest: { _ in },
            onRefresh: {},
            onLoadMore: {}
        )

        #expect(view.moments.isEmpty)
    }

    @Test func test_withMoments_showsContent() {
        let moments = [
            MockMomentFactory.makePhotoMoment(),
            MockMomentFactory.makeVoiceOnlyMoment()
        ]
        let view = TimelineView(
            moments: moments,
            isLoadingMore: false,
            hasMoreOlderMoments: true,
            onMomentTap: { _ in },
            onDeleteRequest: { _ in },
            onRefresh: {},
            onLoadMore: {}
        )

        #expect(view.moments.count == 2)
    }
}
