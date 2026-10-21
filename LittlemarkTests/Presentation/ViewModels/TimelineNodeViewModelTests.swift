import Testing
import Foundation
@testable import Littlemark

struct TimelineNodeViewModelTests {

    // MARK: - Alignment

    @Test func test_evenIndex_isTopAligned() {
        let vm = TimelineNodeViewModel(moment: MockMomentFactory.makePhotoMoment(), index: 0)

        #expect(vm.isTopAligned == true)
    }

    @Test func test_oddIndex_isBottomAligned() {
        let vm = TimelineNodeViewModel(moment: MockMomentFactory.makePhotoMoment(), index: 1)

        #expect(vm.isTopAligned == false)
    }

    @Test func test_index2_isTopAligned() {
        let vm = TimelineNodeViewModel(moment: MockMomentFactory.makePhotoMoment(), index: 2)

        #expect(vm.isTopAligned == true)
    }

    @Test func test_index3_isBottomAligned() {
        let vm = TimelineNodeViewModel(moment: MockMomentFactory.makePhotoMoment(), index: 3)

        #expect(vm.isTopAligned == false)
    }

    // MARK: - Display Title

    @Test func test_displayTitle_delegatesToHelper() {
        let moment = MockMomentFactory.makeMoment(title: "Test Title")
        let vm = TimelineNodeViewModel(moment: moment, index: 0)

        #expect(vm.displayTitle == "Test Title")
    }

    @Test func test_displayTitle_noTitle_usesText() {
        let moment = MockMomentFactory.makeMoment(title: nil, text: "Some text")
        let vm = TimelineNodeViewModel(moment: moment, index: 0)

        #expect(vm.displayTitle == "Some text")
    }

    // MARK: - Category Emoji

    @Test func test_categoryEmoji_withCategory_returnsEmoji() {
        let category = MomentCategory.predefined[0]
        let moment = MockMomentFactory.makeMoment(categories: [category])
        let vm = TimelineNodeViewModel(moment: moment, index: 0)

        #expect(vm.categoryEmoji == category.emoji)
    }

    @Test func test_categoryEmoji_noCategory_returnsNil() {
        let moment = MockMomentFactory.makeMoment(categories: [])
        let vm = TimelineNodeViewModel(moment: moment, index: 0)

        #expect(vm.categoryEmoji == nil)
    }

    // MARK: - Badges

    @Test func test_photoBadge_photoMoment() {
        let vm = TimelineNodeViewModel(moment: MockMomentFactory.makePhotoMoment(), index: 0)

        #expect(vm.hasPhotoBadge == true)
        #expect(vm.hasVideoBadge == false)
        #expect(vm.hasVoiceBadge == false)
    }

    @Test func test_voiceBadge_voiceOnlyMoment() {
        let vm = TimelineNodeViewModel(moment: MockMomentFactory.makeVoiceOnlyMoment(), index: 0)

        #expect(vm.hasPhotoBadge == false)
        #expect(vm.hasVideoBadge == false)
        #expect(vm.hasVoiceBadge == true)
    }

    @Test func test_allBadges_fullMoment() {
        let vm = TimelineNodeViewModel(moment: MockMomentFactory.makeFullMoment(), index: 0)

        #expect(vm.hasPhotoBadge == true)
        #expect(vm.hasVideoBadge == true)
        #expect(vm.hasVoiceBadge == true)
    }

    // MARK: - Moment ID

    @Test func test_momentId_matchesMomentId() {
        let moment = MockMomentFactory.makePhotoMoment()
        let vm = TimelineNodeViewModel(moment: moment, index: 0)

        #expect(vm.momentId == moment.id)
    }
}
