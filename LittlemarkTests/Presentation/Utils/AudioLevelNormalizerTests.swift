import Testing
import Foundation
@testable import Littlemark

struct AudioLevelNormalizerTests {

    // MARK: - Normalize

    @Test func test_normalize_silentLevel_returnsZero() {
        let result = AudioLevelNormalizer.normalize(decibels: -160)
        #expect(result == 0)
    }

    @Test func test_normalize_minusSeventyDB_returnsZero() {
        let result = AudioLevelNormalizer.normalize(decibels: -70)
        #expect(result == 0)
    }

    @Test func test_normalize_minusSixtyDB_returnsZero() {
        let result = AudioLevelNormalizer.normalize(decibels: -60)
        #expect(result == 0)
    }

    @Test func test_normalize_minusThirtyDB_returnsHalf() {
        let result = AudioLevelNormalizer.normalize(decibels: -30)
        #expect(result == 0.5)
    }

    @Test func test_normalize_zeroDB_returnsOne() {
        let result = AudioLevelNormalizer.normalize(decibels: 0)
        #expect(result == 1.0)
    }

    @Test func test_normalize_minusTwentyDB_returnsTwoThirds() {
        let result = AudioLevelNormalizer.normalize(decibels: -20)
        let expected = CGFloat(40.0 / 60.0)
        #expect(abs(result - expected) < 0.001)
    }

    @Test func test_normalize_minusFifteenDB_returnsThreeQuarters() {
        let result = AudioLevelNormalizer.normalize(decibels: -15)
        #expect(result == 0.75)
    }

    // MARK: - Append Level

    @Test func test_appendLevel_addsToArray() {
        var levels: [CGFloat] = []
        AudioLevelNormalizer.appendLevel(0.5, to: &levels)
        #expect(levels == [0.5])
    }

    @Test func test_appendLevel_multipleAdds() {
        var levels: [CGFloat] = []
        AudioLevelNormalizer.appendLevel(0.1, to: &levels)
        AudioLevelNormalizer.appendLevel(0.2, to: &levels)
        AudioLevelNormalizer.appendLevel(0.3, to: &levels)
        #expect(levels == [0.1, 0.2, 0.3])
    }

    @Test func test_appendLevel_exceedsMaxCount_removesFirst() {
        var levels: [CGFloat] = []
        for i in 0..<40 {
            AudioLevelNormalizer.appendLevel(CGFloat(i) / 40.0, to: &levels)
        }
        #expect(levels.count == 40)

        AudioLevelNormalizer.appendLevel(0.99, to: &levels)
        #expect(levels.count == 40)
        #expect(levels.last == 0.99)
        #expect(levels.first == CGFloat(1) / 40.0)
    }

    @Test func test_appendLevel_customMaxCount() {
        var levels: [CGFloat] = []
        for _ in 0..<5 {
            AudioLevelNormalizer.appendLevel(0.5, to: &levels, maxCount: 3)
        }
        #expect(levels.count == 3)
    }

    @Test func test_appendLevel_emptyArrayWithMaxCountOne() {
        var levels: [CGFloat] = []
        AudioLevelNormalizer.appendLevel(0.1, to: &levels, maxCount: 1)
        AudioLevelNormalizer.appendLevel(0.2, to: &levels, maxCount: 1)
        #expect(levels.count == 1)
        #expect(levels.first == 0.2)
    }
}
