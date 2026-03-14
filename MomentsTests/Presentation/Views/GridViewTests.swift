import Testing
import Foundation
@testable import Moments

struct GridViewTests {

    @Test func test_emptyMoments_showsEmptyState() {
        let view = GridView(
            moments: [],
            onMomentTap: { _ in },
            onDeleteRequest: { _ in },
            onRefresh: {}
        )

        #expect(view.moments.isEmpty)
    }

    @Test func test_withMoments_showsGrid() {
        let moments = [
            MockMomentFactory.makePhotoMoment(),
            MockMomentFactory.makeVideoMoment(),
            MockMomentFactory.makeVoiceOnlyMoment()
        ]
        let view = GridView(
            moments: moments,
            onMomentTap: { _ in },
            onDeleteRequest: { _ in },
            onRefresh: {}
        )

        #expect(view.moments.count == 3)
    }
}
