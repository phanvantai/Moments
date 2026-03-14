import Testing
import Foundation
@testable import Moments

struct ViewModeTests {

    @Test func test_timeline_rawValue() {
        #expect(ViewMode.timeline.rawValue == "timeline")
    }

    @Test func test_grid_rawValue() {
        #expect(ViewMode.grid.rawValue == "grid")
    }

    @Test func test_initFromRawValue_timeline() {
        let mode = ViewMode(rawValue: "timeline")

        #expect(mode == .timeline)
    }

    @Test func test_initFromRawValue_grid() {
        let mode = ViewMode(rawValue: "grid")

        #expect(mode == .grid)
    }

    @Test func test_initFromRawValue_invalid_returnsNil() {
        let mode = ViewMode(rawValue: "invalid")

        #expect(mode == nil)
    }
}
