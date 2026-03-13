import Testing
import Foundation
@testable import Moments

struct CategoryTests {

    @Test func test_predefined_hasTenCategories() {
        #expect(MomentCategory.predefined.count == 10)
    }

    @Test func test_predefined_allKeysUnique() {
        let keys = MomentCategory.predefined.map(\.key)
        #expect(Set(keys).count == keys.count)
    }

    @Test func test_predefined_containsExpectedKeys() {
        let keys = Set(MomentCategory.predefined.map(\.key))
        let expected: Set<String> = [
            "first-time", "milestone", "daily", "outdoor", "family",
            "health", "travel", "food", "play", "learn"
        ]
        #expect(keys == expected)
    }

    @Test func test_findByKey_existingKey_returnsCategory() {
        let category = MomentCategory.find(byKey: "travel")
        #expect(category != nil)
        #expect(category?.label == "Du lịch")
        #expect(category?.emoji == "✈️")
    }

    @Test func test_findByKey_nonExistingKey_returnsNil() {
        let category = MomentCategory.find(byKey: "nonexistent")
        #expect(category == nil)
    }

    @Test func test_id_equalsKey() {
        let category = MomentCategory(key: "test", label: "Test", emoji: "🧪", colorKey: "testColor", keywords: [])
        #expect(category.id == "test")
    }

    @Test func test_predefined_dailyHasNoKeywords() {
        let daily = MomentCategory.find(byKey: "daily")
        #expect(daily?.keywords.isEmpty == true)
    }

    @Test func test_predefined_firstTimeHasKeywords() {
        let firstTime = MomentCategory.find(byKey: "first-time")
        #expect(firstTime?.keywords.isEmpty == false)
        #expect(firstTime?.keywords.contains("đầu tiên") == true)
    }

    @Test func test_equatable_sameCategories_areEqual() {
        let c1 = MomentCategory(key: "test", label: "Test", emoji: "🧪", colorKey: "c", keywords: ["a"])
        let c2 = MomentCategory(key: "test", label: "Test", emoji: "🧪", colorKey: "c", keywords: ["a"])
        #expect(c1 == c2)
    }
}
