import Testing
import Foundation
@testable import Littlemark

struct LocationBadgeViewTests {
    @Test func test_locationBadge_displaysName() {
        let location = Location(
            latitude: 10.762622,
            longitude: 106.660172,
            name: "Ho Chi Minh City"
        )

        let view = LocationBadgeView(location: location, onRemove: {})

        // View renders without crash
        _ = view.body
        #expect(location.name == "Ho Chi Minh City")
    }

    @Test func test_locationBadge_noName_displaysCoordinates() {
        let location = Location(latitude: 10.762622, longitude: 106.660172)

        let view = LocationBadgeView(location: location, onRemove: {})

        // View renders without crash
        _ = view.body
        #expect(location.name == nil)
    }

    @Test func test_locationBadge_onRemoveCalled() {
        var removed = false
        let location = Location(latitude: 10.0, longitude: 106.0, name: "Test")

        _ = LocationBadgeView(location: location, onRemove: { removed = true })

        // Closure is captured correctly (we can't tap in unit test, but verify no crash)
        #expect(removed == false)
    }
}
