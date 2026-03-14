import Testing
import Foundation
import SwiftUI
@testable import Moments

struct MomentDisplayHelperTests {

    // MARK: - Display Title

    @Test func test_displayTitle_withTitle_returnsTitle() {
        let moment = MockMomentFactory.makeMoment(title: "My Title", text: "Some text")

        #expect(MomentDisplayHelper.displayTitle(for: moment) == "My Title")
    }

    @Test func test_displayTitle_withEmptyTitle_returnsTextSnippet() {
        let moment = MockMomentFactory.makeMoment(title: "", text: "Some long text description")

        #expect(MomentDisplayHelper.displayTitle(for: moment) == "Some long text description")
    }

    @Test func test_displayTitle_noTitle_returnsTextSnippet() {
        let moment = MockMomentFactory.makeMoment(title: nil, text: "This is a long text description of the moment")

        #expect(MomentDisplayHelper.displayTitle(for: moment) == "This is a long text descriptio")
    }

    @Test func test_displayTitle_noTitleNoText_returnsCategoryLabel() {
        let category = MomentCategory.predefined[0]
        let moment = MockMomentFactory.makeMoment(title: nil, text: nil, categories: [category])

        #expect(MomentDisplayHelper.displayTitle(for: moment) == category.label)
    }

    @Test func test_displayTitle_nothing_returnsMoment() {
        let moment = MockMomentFactory.makeMoment(title: nil, text: nil, categories: [])

        #expect(MomentDisplayHelper.displayTitle(for: moment) == "Moment")
    }

    // MARK: - Category Color

    @Test func test_categoryColor_noCategory_returnsBlue() {
        let moment = MockMomentFactory.makeMoment(categories: [])
        let color = MomentDisplayHelper.categoryColor(for: moment)

        #expect(color == .blue)
    }

    @Test func test_categoryColor_firstTime_returnsYellow() {
        let color = MomentDisplayHelper.color(forCategoryKey: "first-time")

        #expect(color == .yellow)
    }

    @Test func test_categoryColor_travel_returnsCyan() {
        let color = MomentDisplayHelper.color(forCategoryKey: "travel")

        #expect(color == .cyan)
    }

    @Test func test_categoryColor_unknownKey_returnsBlue() {
        let color = MomentDisplayHelper.color(forCategoryKey: "unknown")

        #expect(color == .blue)
    }

    // MARK: - Badge Helpers

    @Test func test_hasPhotoBadge_photoMoment_returnsTrue() {
        let moment = MockMomentFactory.makePhotoMoment()

        #expect(MomentDisplayHelper.hasPhotoBadge(moment) == true)
    }

    @Test func test_hasPhotoBadge_voiceOnlyMoment_returnsFalse() {
        let moment = MockMomentFactory.makeVoiceOnlyMoment()

        #expect(MomentDisplayHelper.hasPhotoBadge(moment) == false)
    }

    @Test func test_hasVideoBadge_videoMoment_returnsTrue() {
        let moment = MockMomentFactory.makeVideoMoment()

        #expect(MomentDisplayHelper.hasVideoBadge(moment) == true)
    }

    @Test func test_hasVoiceBadge_voiceMoment_returnsTrue() {
        let moment = MockMomentFactory.makeVoiceOnlyMoment()

        #expect(MomentDisplayHelper.hasVoiceBadge(moment) == true)
    }

    @Test func test_hasVoiceBadge_photoMoment_returnsFalse() {
        let moment = MockMomentFactory.makePhotoMoment()

        #expect(MomentDisplayHelper.hasVoiceBadge(moment) == false)
    }

    // MARK: - Thumbnail URL

    @Test func test_thumbnailURL_noMedia_returnsNil() {
        let moment = MockMomentFactory.makeVoiceOnlyMoment()

        #expect(MomentDisplayHelper.thumbnailURL(for: moment) == nil)
    }

    @Test func test_thumbnailURL_withMedia_returnsURL() {
        let moment = MockMomentFactory.makePhotoMoment()

        #expect(MomentDisplayHelper.thumbnailURL(for: moment) != nil)
    }

    @Test func test_thumbnailURL_videoWithThumbnail_usesThumbnailPath() {
        let moment = MockMomentFactory.makeVideoMoment()
        let url = MomentDisplayHelper.thumbnailURL(for: moment)

        #expect(url != nil)
        #expect(url!.lastPathComponent.contains("thumb"))
    }
}
