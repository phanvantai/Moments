import Testing
import Foundation
@testable import Littlemark

struct DurationFormatterTests {

    // MARK: - Short Format

    @Test func test_shortFormat_zero_returns0_00() {
        #expect(DurationFormatter.shortFormat(0) == "0:00")
    }

    @Test func test_shortFormat_30seconds_returns0_30() {
        #expect(DurationFormatter.shortFormat(30) == "0:30")
    }

    @Test func test_shortFormat_60seconds_returns1_00() {
        #expect(DurationFormatter.shortFormat(60) == "1:00")
    }

    @Test func test_shortFormat_65seconds_returns1_05() {
        #expect(DurationFormatter.shortFormat(65) == "1:05")
    }

    @Test func test_shortFormat_125seconds_returns2_05() {
        #expect(DurationFormatter.shortFormat(125) == "2:05")
    }

    @Test func test_shortFormat_600seconds_returns10_00() {
        #expect(DurationFormatter.shortFormat(600) == "10:00")
    }

    @Test func test_shortFormat_3599seconds_returns59_59() {
        #expect(DurationFormatter.shortFormat(3599) == "59:59")
    }

    @Test func test_shortFormat_3600seconds_returns60_00() {
        #expect(DurationFormatter.shortFormat(3600) == "60:00")
    }

    // MARK: - Padded Format

    @Test func test_paddedFormat_zero_returns00_00() {
        #expect(DurationFormatter.paddedFormat(0) == "00:00")
    }

    @Test func test_paddedFormat_30seconds_returns00_30() {
        #expect(DurationFormatter.paddedFormat(30) == "00:30")
    }

    @Test func test_paddedFormat_65seconds_returns01_05() {
        #expect(DurationFormatter.paddedFormat(65) == "01:05")
    }

    @Test func test_paddedFormat_600seconds_returns10_00() {
        #expect(DurationFormatter.paddedFormat(600) == "10:00")
    }

    @Test func test_paddedFormat_5seconds_returns00_05() {
        #expect(DurationFormatter.paddedFormat(5) == "00:05")
    }

    @Test func test_paddedFormat_90seconds_returns01_30() {
        #expect(DurationFormatter.paddedFormat(90) == "01:30")
    }
}
