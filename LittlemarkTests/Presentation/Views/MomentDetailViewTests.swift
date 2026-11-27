import Testing
import Foundation
@testable import Littlemark

@MainActor
struct MomentDetailViewTests {

    // MARK: - View Construction with ViewModel

    @Test func test_viewCreation_noLocation_mapHidden() {
        let moment = MockMomentFactory.makeMoment(location: nil)
        let vm = MomentDetailViewModel(moment: moment)
        let view = MomentDetailView(viewModel: vm, onDismiss: {})

        #expect(view.viewModel.showMap == false)
    }

    @Test func test_viewCreation_withLocation_mapShown() {
        let location = MockMomentFactory.makeLocation()
        let moment = MockMomentFactory.makeMoment(location: location)
        let vm = MomentDetailViewModel(moment: moment)
        let view = MomentDetailView(viewModel: vm, onDismiss: {})

        #expect(view.viewModel.showMap == true)
    }

    // MARK: - Weather visibility

    @Test func test_viewCreation_noWeather_weatherHidden() {
        let moment = MockMomentFactory.makeMoment(weather: nil)
        let vm = MomentDetailViewModel(moment: moment)
        let view = MomentDetailView(viewModel: vm, onDismiss: {})

        #expect(view.viewModel.showWeather == false)
    }

    @Test func test_viewCreation_withWeather_weatherShown() {
        let weather = MockMomentFactory.makeWeather()
        let moment = MockMomentFactory.makeMoment(weather: weather)
        let vm = MomentDetailViewModel(moment: moment)
        let view = MomentDetailView(viewModel: vm, onDismiss: {})

        #expect(view.viewModel.showWeather == true)
    }

    // MARK: - Voice player visibility

    @Test func test_viewCreation_noVoice_playerHidden() {
        let moment = MockMomentFactory.makeMoment(voiceNote: nil)
        let vm = MomentDetailViewModel(moment: moment)
        let view = MomentDetailView(viewModel: vm, onDismiss: {})

        #expect(view.viewModel.showVoicePlayer == false)
    }

    @Test func test_viewCreation_withVoice_playerShown() {
        let voiceNote = MockMomentFactory.makeVoiceNote()
        let moment = MockMomentFactory.makeMoment(voiceNote: voiceNote)
        let vm = MomentDetailViewModel(moment: moment)
        let view = MomentDetailView(viewModel: vm, onDismiss: {})

        #expect(view.viewModel.showVoicePlayer == true)
    }

    // MARK: - Pager dots

    @Test func test_viewCreation_singleMedia_noPagerDots() {
        let moment = MockMomentFactory.makePhotoMoment()
        let vm = MomentDetailViewModel(moment: moment)
        let view = MomentDetailView(viewModel: vm, onDismiss: {})

        #expect(view.viewModel.showPagerDots == false)
    }

    @Test func test_viewCreation_multipleMedia_showsPagerDots() {
        let moment = MockMomentFactory.makeFullMoment()
        let vm = MomentDetailViewModel(moment: moment)
        let view = MomentDetailView(viewModel: vm, onDismiss: {})

        #expect(view.viewModel.showPagerDots == true)
    }

    @Test func test_viewCreation_noMedia_noPagerDots() {
        let moment = MockMomentFactory.makeVoiceOnlyMoment()
        let vm = MomentDetailViewModel(moment: moment)
        let view = MomentDetailView(viewModel: vm, onDismiss: {})

        #expect(view.viewModel.showPagerDots == false)
    }
}
