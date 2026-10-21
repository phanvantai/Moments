import Testing
import Foundation
@testable import Littlemark

struct MomentVisibilityTests {

    @Test func test_rawValues_areCorrect() {
        #expect(MomentVisibility.private.rawValue == "private")
        #expect(MomentVisibility.shared.rawValue == "shared")
        #expect(MomentVisibility.public.rawValue == "public")
    }

    @Test func test_initFromRawValue_validValues_succeed() {
        #expect(MomentVisibility(rawValue: "private") == .private)
        #expect(MomentVisibility(rawValue: "shared") == .shared)
        #expect(MomentVisibility(rawValue: "public") == .public)
    }

    @Test func test_initFromRawValue_invalidValue_returnsNil() {
        #expect(MomentVisibility(rawValue: "unknown") == nil)
    }
}
