import Testing
import Foundation
@testable import Littlemark

@MainActor
struct MomentDetailViewModelTests {

    // MARK: - Weather Attribution

    @Test func test_loadWeatherAttribution_withWeather_setsAttribution() async {
        let weatherService = MockWeatherService()
        let moment = MockMomentFactory.makeMoment(weather: MockMomentFactory.makeWeather())
        let vm = MomentDetailViewModel(moment: moment, weatherService: weatherService)

        await vm.loadWeatherAttribution()

        #expect(vm.weatherAttribution == weatherService.attributionToReturn)
    }

    @Test func test_loadWeatherAttribution_noWeather_skipsFetch() async {
        let weatherService = MockWeatherService()
        let moment = MockMomentFactory.makeMoment(weather: nil)
        let vm = MomentDetailViewModel(moment: moment, weatherService: weatherService)

        await vm.loadWeatherAttribution()

        #expect(vm.weatherAttribution == nil)
        #expect(weatherService.fetchAttributionCallCount == 0)
    }

    // MARK: - Visibility

    @Test func test_showMap_noLocation_returnsFalse() {
        let moment = MockMomentFactory.makeMoment(location: nil)
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.showMap == false)
    }

    @Test func test_showMap_withLocation_returnsTrue() {
        let moment = MockMomentFactory.makeMoment(location: MockMomentFactory.makeLocation())
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.showMap == true)
    }

    @Test func test_showWeather_noWeather_returnsFalse() {
        let moment = MockMomentFactory.makeMoment(weather: nil)
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.showWeather == false)
    }

    @Test func test_showWeather_withWeather_returnsTrue() {
        let moment = MockMomentFactory.makeMoment(weather: MockMomentFactory.makeWeather())
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.showWeather == true)
    }

    @Test func test_showVoicePlayer_noVoice_returnsFalse() {
        let moment = MockMomentFactory.makeMoment(voiceNote: nil)
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.showVoicePlayer == false)
    }

    @Test func test_showVoicePlayer_withVoice_returnsTrue() {
        let moment = MockMomentFactory.makeMoment(voiceNote: MockMomentFactory.makeVoiceNote())
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.showVoicePlayer == true)
    }

    // MARK: - Pager Dots

    @Test func test_showPagerDots_singleMedia_returnsFalse() {
        let moment = MockMomentFactory.makePhotoMoment()
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.showPagerDots == false)
    }

    @Test func test_showPagerDots_multipleMedia_returnsTrue() {
        let moment = MockMomentFactory.makeFullMoment()
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.showPagerDots == true)
    }

    @Test func test_showPagerDots_noMedia_returnsFalse() {
        let moment = MockMomentFactory.makeVoiceOnlyMoment()
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.showPagerDots == false)
    }

    // MARK: - Has Content

    @Test func test_hasMedia_withMedia_returnsTrue() {
        let moment = MockMomentFactory.makePhotoMoment()
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.hasMedia == true)
    }

    @Test func test_hasMedia_noMedia_returnsFalse() {
        let moment = MockMomentFactory.makeVoiceOnlyMoment()
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.hasMedia == false)
    }

    @Test func test_hasCategories_withCategories_returnsTrue() {
        let moment = MockMomentFactory.makeFullMoment()
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.hasCategories == true)
    }

    @Test func test_hasCategories_noCategories_returnsFalse() {
        let moment = MockMomentFactory.makeMoment(categories: [])
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.hasCategories == false)
    }

    @Test func test_hasTags_withTags_returnsTrue() {
        let moment = MockMomentFactory.makeFullMoment()
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.hasTags == true)
    }

    @Test func test_hasTags_noTags_returnsFalse() {
        let moment = MockMomentFactory.makeMoment(tags: [])
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.hasTags == false)
    }

    // MARK: - Title / Text

    @Test func test_title_withTitle_returnsTitle() {
        let moment = MockMomentFactory.makeMoment(title: "Hello")
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.title == "Hello")
    }

    @Test func test_title_emptyTitle_returnsNil() {
        let moment = MockMomentFactory.makeMoment(title: "")
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.title == nil)
    }

    @Test func test_title_nilTitle_returnsNil() {
        let moment = MockMomentFactory.makeMoment(title: nil)
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.title == nil)
    }

    @Test func test_text_withText_returnsText() {
        let moment = MockMomentFactory.makeMoment(text: "Description")
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.text == "Description")
    }

    @Test func test_text_emptyText_returnsNil() {
        let moment = MockMomentFactory.makeMoment(text: "")
        let vm = MomentDetailViewModel(moment: moment)

        #expect(vm.text == nil)
    }
}
