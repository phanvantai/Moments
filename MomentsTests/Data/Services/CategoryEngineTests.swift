import Testing
import Foundation
@testable import Moments

struct CategoryEngineTests {
    let sut = CategoryEngine()

    // MARK: - NLP: Text Analysis

    @Test func test_nlp_lanDauBietDi_containsFirstTime() {
        let results = sut.analyzeText("lần đầu biết đi", transcript: nil)
        let keys = results.map(\.key)
        #expect(keys.contains("first-time"))
    }

    @Test func test_nlp_sinhNhat_containsMilestone() {
        let results = sut.analyzeText("sinh nhật", transcript: nil)
        let keys = results.map(\.key)
        #expect(keys.contains("milestone"))
    }

    @Test func test_nlp_congVien_containsOutdoor() {
        let results = sut.analyzeText("công viên", transcript: nil)
        let keys = results.map(\.key)
        #expect(keys.contains("outdoor"))
    }

    @Test func test_nlp_ongBa_containsFamily() {
        let results = sut.analyzeText("ông bà", transcript: nil)
        let keys = results.map(\.key)
        #expect(keys.contains("family"))
    }

    @Test func test_nlp_anBanh_containsFood() {
        let results = sut.analyzeText("ăn bánh", transcript: nil)
        let keys = results.map(\.key)
        #expect(keys.contains("food"))
    }

    @Test func test_nlp_emptyText_noSuggestions() {
        let results = sut.analyzeText("", transcript: nil)
        #expect(results.isEmpty)
    }

    @Test func test_nlp_nilText_noSuggestions() {
        let results = sut.analyzeText(nil, transcript: nil)
        #expect(results.isEmpty)
    }

    @Test func test_nlp_nilBoth_noSuggestions() {
        let results = sut.analyzeText(nil, transcript: nil)
        #expect(results.isEmpty)
    }

    @Test func test_nlp_transcript_matchesKeywords() {
        let results = sut.analyzeText(nil, transcript: "ông bà đi chơi công viên")
        let keys = results.map(\.key)
        #expect(keys.contains("family"))
        #expect(keys.contains("outdoor"))
        #expect(keys.contains("play"))
    }

    @Test func test_nlp_textAndTranscript_combinedMatching() {
        let results = sut.analyzeText("sinh nhật", transcript: "ăn bánh")
        let keys = results.map(\.key)
        #expect(keys.contains("milestone"))
        #expect(keys.contains("food"))
    }

    // MARK: - Vision: Image Classification

    @Test func test_vision_outdoorLabel_suggestsOutdoor() {
        let results = sut.mapVisionLabels(["outdoor", "sky"])
        let keys = results.map(\.key)
        #expect(keys.contains("outdoor"))
    }

    @Test func test_vision_imageNil_skipsSafely() async {
        let results = await sut.analyzeImages(nil)
        #expect(results.isEmpty)
    }

    @Test func test_vision_emptyImageData_skipsSafely() async {
        let results = await sut.analyzeImages([])
        #expect(results.isEmpty)
    }

    @Test func test_vision_foodLabel_suggestsFood() {
        let results = sut.mapVisionLabels(["food", "meal"])
        let keys = results.map(\.key)
        #expect(keys.contains("food"))
    }

    @Test func test_vision_personLabel_suggestsFamily() {
        let results = sut.mapVisionLabels(["person", "baby"])
        let keys = results.map(\.key)
        #expect(keys.contains("family"))
    }

    @Test func test_vision_duplicateLabelsFromSameCategory_mergedToOne() {
        let results = sut.mapVisionLabels(["outdoor", "sky", "tree", "landscape"])
        let keys = results.map(\.key)
        let outdoorCount = keys.filter { $0 == "outdoor" }.count
        #expect(outdoorCount == 1)
    }

    // MARK: - Location Analysis

    @Test func test_location_placeTypePark_suggestsOutdoor() {
        let location = Location(latitude: 10.0, longitude: 106.0, placeType: "park")
        let results = sut.analyzeLocation(location)
        let keys = results.map(\.key)
        #expect(keys.contains("outdoor"))
    }

    @Test func test_location_placeTypeHospital_suggestsHealth() {
        let location = Location(latitude: 10.0, longitude: 106.0, placeType: "hospital")
        let results = sut.analyzeLocation(location)
        let keys = results.map(\.key)
        #expect(keys.contains("health"))
    }

    @Test func test_location_placeTypeRestaurant_suggestsFood() {
        let location = Location(latitude: 10.0, longitude: 106.0, placeType: "restaurant")
        let results = sut.analyzeLocation(location)
        let keys = results.map(\.key)
        #expect(keys.contains("food"))
    }

    @Test func test_location_nilPlaceType_noSuggestions() {
        let location = Location(latitude: 10.0, longitude: 106.0)
        let results = sut.analyzeLocation(location)
        #expect(results.isEmpty)
    }

    @Test func test_location_nilLocation_noSuggestions() {
        let results = sut.analyzeLocation(nil)
        #expect(results.isEmpty)
    }

    // MARK: - Combined Signals

    @Test func test_combined_multiSignal_sortedByConfidence() async {
        let results = await sut.suggest(
            text: "ăn ở nhà hàng",
            voiceTranscript: nil,
            imageData: nil,
            location: Location(latitude: 10.0, longitude: 106.0, placeType: "restaurant")
        )
        // "food" should be top because both NLP (ăn) and location (restaurant) contribute
        #expect(results.first == "food")
    }

    @Test func test_combined_anONhaHang_plusLocationRestaurant_foodTop() async {
        let results = await sut.suggest(
            text: "ăn ở nhà hàng",
            voiceTranscript: nil,
            imageData: nil,
            location: Location(latitude: 10.0, longitude: 106.0, placeType: "restaurant")
        )
        #expect(results.first == "food")
    }

    @Test func test_combined_noInput_returnsDaily() async {
        let results = await sut.suggest(
            text: nil,
            voiceTranscript: nil,
            imageData: nil,
            location: nil
        )
        #expect(results == ["daily"])
    }

    @Test func test_combined_emptyStrings_returnsDaily() async {
        let results = await sut.suggest(
            text: "",
            voiceTranscript: "",
            imageData: nil,
            location: nil
        )
        #expect(results == ["daily"])
    }

    @Test func test_combined_duplicatesMerged() async {
        // "công viên" NLP → outdoor, location park → outdoor
        // Both should merge into single "outdoor" entry
        let results = await sut.suggest(
            text: "công viên",
            voiceTranscript: nil,
            imageData: nil,
            location: Location(latitude: 10.0, longitude: 106.0, placeType: "park")
        )
        let outdoorCount = results.filter { $0 == "outdoor" }.count
        #expect(outdoorCount == 1)
        #expect(results.contains("outdoor"))
    }

    @Test func test_combined_multipleCategories_allReturned() async {
        let results = await sut.suggest(
            text: "ông bà đi chơi công viên ăn bánh",
            voiceTranscript: nil,
            imageData: nil,
            location: nil
        )
        #expect(results.contains("family"))
        #expect(results.contains("outdoor"))
        #expect(results.contains("food"))
        #expect(results.contains("play"))
    }
}
