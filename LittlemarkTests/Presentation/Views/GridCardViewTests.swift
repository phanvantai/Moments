import Testing
import Foundation
@testable import Littlemark

struct GridCardViewTests {

    // MARK: - View Construction with ViewModel

    @Test func test_viewCreation_withViewModel() {
        let moment = MockMomentFactory.makeMoment(title: "My Title", text: "Some text")
        let vm = GridCardViewModel(moment: moment)
        let view = GridCardView(viewModel: vm)

        #expect(view.viewModel.displayTitle == "My Title")
    }

    @Test func test_viewCreation_displaysTextSnippet() {
        let moment = MockMomentFactory.makeMoment(title: nil, text: "This is a long text description of the moment")
        let vm = GridCardViewModel(moment: moment)
        let view = GridCardView(viewModel: vm)

        #expect(view.viewModel.displayTitle == "This is a long text descriptio")
    }

    @Test func test_viewCreation_emptyTitle_displaysTextSnippet() {
        let moment = MockMomentFactory.makeMoment(title: "", text: "Some text")
        let vm = GridCardViewModel(moment: moment)
        let view = GridCardView(viewModel: vm)

        #expect(view.viewModel.displayTitle == "Some text")
    }

    @Test func test_viewCreation_noTitleOrText_displaysCategoryLabel() {
        let category = MomentCategory.predefined[0]
        let moment = MockMomentFactory.makeMoment(title: nil, text: nil, categories: [category])
        let vm = GridCardViewModel(moment: moment)
        let view = GridCardView(viewModel: vm)

        #expect(view.viewModel.displayTitle == category.label)
    }

    @Test func test_viewCreation_noContent_displaysMoment() {
        let moment = MockMomentFactory.makeMoment(title: nil, text: nil, categories: [])
        let vm = GridCardViewModel(moment: moment)
        let view = GridCardView(viewModel: vm)

        #expect(view.viewModel.displayTitle == "Moment")
    }

    // MARK: - ViewModel Integration

    @Test func test_viewModel_hasThumbnail_withMedia() {
        let moment = MockMomentFactory.makePhotoMoment()
        let vm = GridCardViewModel(moment: moment)
        let view = GridCardView(viewModel: vm)

        #expect(view.viewModel.hasThumbnail == true)
    }

    @Test func test_viewModel_noThumbnail_withoutMedia() {
        let moment = MockMomentFactory.makeMoment(mediaItems: [])
        let vm = GridCardViewModel(moment: moment)
        let view = GridCardView(viewModel: vm)

        #expect(view.viewModel.hasThumbnail == false)
    }
}
