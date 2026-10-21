import Testing
import Foundation
@testable import Littlemark

struct TimelineNodeViewTests {

    // MARK: - View Construction with ViewModel

    @Test func test_viewCreation_withViewModel() {
        let moment = MockMomentFactory.makePhotoMoment()
        let vm = TimelineNodeViewModel(moment: moment, index: 0)
        let view = TimelineNodeView(viewModel: vm, onTap: {})

        #expect(view.viewModel.momentId == moment.id)
    }

    @Test func test_viewCreation_evenIndex_viewModelIsTopAligned() {
        let moment = MockMomentFactory.makePhotoMoment()
        let vm = TimelineNodeViewModel(moment: moment, index: 0)
        let view = TimelineNodeView(viewModel: vm, onTap: {})

        #expect(view.viewModel.isTopAligned == true)
    }

    @Test func test_viewCreation_oddIndex_viewModelIsBottomAligned() {
        let moment = MockMomentFactory.makePhotoMoment()
        let vm = TimelineNodeViewModel(moment: moment, index: 1)
        let view = TimelineNodeView(viewModel: vm, onTap: {})

        #expect(view.viewModel.isTopAligned == false)
    }

    // MARK: - ViewModel Integration

    @Test func test_viewModel_displayTitle_passedToView() {
        let moment = MockMomentFactory.makeMoment(title: "My Title")
        let vm = TimelineNodeViewModel(moment: moment, index: 0)
        let view = TimelineNodeView(viewModel: vm, onTap: {})

        #expect(view.viewModel.displayTitle == "My Title")
    }

    @Test func test_viewModel_badges_passedToView() {
        let moment = MockMomentFactory.makeFullMoment()
        let vm = TimelineNodeViewModel(moment: moment, index: 0)
        let view = TimelineNodeView(viewModel: vm, onTap: {})

        #expect(view.viewModel.hasPhotoBadge == true)
        #expect(view.viewModel.hasVideoBadge == true)
        #expect(view.viewModel.hasVoiceBadge == true)
    }

    @Test func test_viewModel_categoryEmoji_passedToView() {
        let category = MomentCategory.predefined[0]
        let moment = MockMomentFactory.makeMoment(categories: [category])
        let vm = TimelineNodeViewModel(moment: moment, index: 0)
        let view = TimelineNodeView(viewModel: vm, onTap: {})

        #expect(view.viewModel.categoryEmoji == category.emoji)
    }
}
