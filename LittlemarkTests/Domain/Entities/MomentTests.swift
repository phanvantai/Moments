import Testing
import Foundation
@testable import Littlemark

struct MomentTests {

    // MARK: - Init

    @Test func test_init_defaultValues_hasCorrectDefaults() {
        let moment = Moment(userId: UUID())

        #expect(moment.title == nil)
        #expect(moment.text == nil)
        #expect(moment.mediaItems.isEmpty)
        #expect(moment.voiceNote == nil)
        #expect(moment.location == nil)
        #expect(moment.categories.isEmpty)
        #expect(moment.tags.isEmpty)
        #expect(moment.isFavorite == false)
        #expect(moment.weather == nil)
        #expect(moment.visibility == .private)
    }

    @Test func test_init_withAllValues_storesCorrectly() {
        let moment = MockMomentFactory.makeFullMoment()

        #expect(moment.title == "Full Moment")
        #expect(moment.text == "A moment with everything")
        #expect(moment.mediaItems.count == 2)
        #expect(moment.voiceNote != nil)
        #expect(moment.location != nil)
        #expect(moment.categories.count == 2)
        #expect(moment.tags == ["test", "full"])
        #expect(moment.isFavorite == true)
        #expect(moment.weather != nil)
        #expect(moment.visibility == .private)
    }

    // MARK: - hasMedia

    @Test func test_hasMedia_withMediaItems_returnsTrue() {
        let moment = MockMomentFactory.makePhotoMoment()
        #expect(moment.hasMedia == true)
    }

    @Test func test_hasMedia_withVoiceNote_returnsTrue() {
        let moment = MockMomentFactory.makeVoiceOnlyMoment()
        #expect(moment.hasMedia == true)
    }

    @Test func test_hasMedia_withNoMediaOrVoice_returnsFalse() {
        let moment = MockMomentFactory.makeMoment()
        #expect(moment.hasMedia == false)
    }

    // MARK: - Equatable

    @Test func test_equatable_sameMoments_areEqual() {
        let id = UUID()
        let moment1 = MockMomentFactory.makeMoment(id: id)
        let moment2 = MockMomentFactory.makeMoment(id: id)
        #expect(moment1 == moment2)
    }

    @Test func test_equatable_differentMoments_areNotEqual() {
        let moment1 = MockMomentFactory.makeMoment(id: UUID())
        let moment2 = MockMomentFactory.makeMoment(id: UUID())
        #expect(moment1 != moment2)
    }
}
