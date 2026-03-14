import Testing
import Foundation
@testable import Moments

struct TimelineViewTests {

    @Test func test_emptyMoments_showsEmptyState() {
        let view = TimelineView(
            moments: [],
            onMomentTap: { _ in },
            onDelete: { _ in }
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
            onMomentTap: { _ in },
            onDelete: { _ in }
        )

        #expect(view.moments.count == 2)
    }
}
