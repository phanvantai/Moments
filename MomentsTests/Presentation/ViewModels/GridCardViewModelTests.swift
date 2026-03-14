import Testing
import Foundation
@testable import Moments

struct GridCardViewModelTests {

    // MARK: - Display Title

    @Test func test_displayTitle_withTitle() {
        let moment = MockMomentFactory.makeMoment(title: "My Title", text: "Some text")
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.displayTitle == "My Title")
    }

    @Test func test_displayTitle_noTitle_usesText() {
        let moment = MockMomentFactory.makeMoment(title: nil, text: "This is a long text description of the moment")
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.displayTitle == "This is a long text descriptio")
    }

    @Test func test_displayTitle_emptyTitle_usesText() {
        let moment = MockMomentFactory.makeMoment(title: "", text: "Some text")
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.displayTitle == "Some text")
    }

    @Test func test_displayTitle_noTitleNoText_usesCategoryLabel() {
        let category = MomentCategory.predefined[0]
        let moment = MockMomentFactory.makeMoment(title: nil, text: nil, categories: [category])
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.displayTitle == category.label)
    }

    @Test func test_displayTitle_nothing_returnsMoment() {
        let moment = MockMomentFactory.makeMoment(title: nil, text: nil, categories: [])
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.displayTitle == "Moment")
    }

    // MARK: - Thumbnail

    @Test func test_hasThumbnail_withMedia_returnsTrue() {
        let moment = MockMomentFactory.makePhotoMoment()
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.hasThumbnail == true)
        #expect(vm.thumbnailURL != nil)
    }

    @Test func test_hasThumbnail_noMedia_returnsFalse() {
        let moment = MockMomentFactory.makeVoiceOnlyMoment()
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.hasThumbnail == false)
        #expect(vm.thumbnailURL == nil)
    }

    // MARK: - Category Badges

    @Test func test_categoryBadges_limitedToThree() {
        let categories = Array(MomentCategory.predefined.prefix(5))
        let moment = MockMomentFactory.makeMoment(categories: categories)
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.categoryBadges.count == 3)
    }

    @Test func test_categoryBadges_lessThanThree_showsAll() {
        let categories = [MomentCategory.predefined[0]]
        let moment = MockMomentFactory.makeMoment(categories: categories)
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.categoryBadges.count == 1)
    }

    // MARK: - Placeholder

    @Test func test_placeholderEmoji_withCategory() {
        let category = MomentCategory.predefined[0]
        let moment = MockMomentFactory.makeMoment(categories: [category])
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.placeholderEmoji == category.emoji)
    }

    @Test func test_placeholderEmoji_noCategory() {
        let moment = MockMomentFactory.makeMoment(categories: [])
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.placeholderEmoji == nil)
    }

    // MARK: - Voice Only

    @Test func test_isVoiceOnly_voiceMoment_returnsTrue() {
        let moment = MockMomentFactory.makeVoiceOnlyMoment()
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.isVoiceOnly == true)
    }

    @Test func test_isVoiceOnly_photoMoment_returnsFalse() {
        let moment = MockMomentFactory.makePhotoMoment()
        let vm = GridCardViewModel(moment: moment)

        #expect(vm.isVoiceOnly == false)
    }
}
