import Testing
import Foundation
import SwiftUI
@testable import Littlemark

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

    @Test func test_displayTitle_noTitle_returnsFullText_viewTruncatesWithEllipsis() {
        let moment = MockMomentFactory.makeMoment(title: nil, text: "This is a long text description of the moment")

        #expect(MomentDisplayHelper.displayTitle(for: moment) == "This is a long text description of the moment")
    }

    @Test func test_displayTitle_noTitleNoText_returnsCategoryLabel() {
        let category = MomentCategory.predefined[0]
        let moment = MockMomentFactory.makeMoment(title: nil, text: nil, categories: [category])

        #expect(MomentDisplayHelper.displayTitle(for: moment) == MomentDisplayHelper.label(for: category))
    }

    @Test func test_displayTitle_nothing_returnsMoment() {
        let moment = MockMomentFactory.makeMoment(title: nil, text: nil, categories: [])

        #expect(MomentDisplayHelper.displayTitle(for: moment) == "Moment")
    }

    // MARK: - Category Label

    private func bundle(for language: String) throws -> Bundle {
        let path = try #require(Bundle.main.path(forResource: language, ofType: "lproj"))
        return try #require(Bundle(path: path))
    }

    @Test(arguments: [("en", "Travel"), ("vi", "Du lịch"), ("ja", "旅行")])
    func test_label_followsLanguage(language: String, expected: String) throws {
        let travel = try #require(MomentCategory.find(byKey: "travel"))

        #expect(MomentDisplayHelper.label(for: travel, bundle: try bundle(for: language)) == expected)
    }

    @Test(arguments: ["en", "vi", "ja"])
    func test_label_everyCategoryIsTranslated(language: String) throws {
        let bundle = try bundle(for: language)

        for category in MomentCategory.predefined {
            let label = MomentDisplayHelper.label(for: category, bundle: bundle)
            #expect(!label.isEmpty)
            #expect(label != "category.\(category.key)")
        }
    }

    @Test func test_label_english_differsFromVietnameseDefault() throws {
        let english = try bundle(for: "en")

        for category in MomentCategory.predefined {
            #expect(MomentDisplayHelper.label(for: category, bundle: english) != category.label)
        }
    }

    // MARK: - Category Color

    @Test func test_categoryColor_noCategory_returnsBlue() {
        let moment = MockMomentFactory.makeMoment(categories: [])
        let color = MomentDisplayHelper.categoryColor(for: moment)

        #expect(color == BrandColors.categoryBlue)
    }

    @Test func test_categoryColor_firstTime_returnsYellow() {
        let color = MomentDisplayHelper.color(forCategoryKey: "first-time")

        #expect(color == BrandColors.categoryYellow)
    }

    @Test func test_categoryColor_travel_returnsCyan() {
        let color = MomentDisplayHelper.color(forCategoryKey: "travel")

        #expect(color == BrandColors.categoryCyan)
    }

    @Test func test_categoryColor_unknownKey_returnsBlue() {
        let color = MomentDisplayHelper.color(forCategoryKey: "unknown")

        #expect(color == BrandColors.categoryBlue)
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
