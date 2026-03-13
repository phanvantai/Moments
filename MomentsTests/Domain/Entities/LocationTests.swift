import Testing
import Foundation
@testable import Moments

struct LocationTests {

    @Test func test_init_withAllValues_storesCorrectly() {
        let location = Location(
            latitude: 10.762622,
            longitude: 106.660172,
            name: "HCMC",
            address: "123 Nguyen Hue",
            placeType: "city"
        )

        #expect(location.latitude == 10.762622)
        #expect(location.longitude == 106.660172)
        #expect(location.name == "HCMC")
        #expect(location.address == "123 Nguyen Hue")
        #expect(location.placeType == "city")
    }

    @Test func test_init_withDefaults_optionalsAreNil() {
        let location = Location(latitude: 0, longitude: 0)
        #expect(location.name == nil)
        #expect(location.address == nil)
        #expect(location.placeType == nil)
    }

    @Test func test_distance_samePoint_isZero() {
        let loc = Location(latitude: 10.0, longitude: 106.0)
        let distance = loc.distance(to: loc)
        #expect(distance < 0.01)
    }

    @Test func test_distance_knownPoints_isApproximatelyCorrect() {
        // HCMC to Hanoi ~ 1,138 km
        let hcmc = Location(latitude: 10.762622, longitude: 106.660172)
        let hanoi = Location(latitude: 21.028511, longitude: 105.804817)
        let distance = hcmc.distance(to: hanoi)
        let distanceKm = distance / 1000

        #expect(distanceKm > 1100)
        #expect(distanceKm < 1200)
    }

    @Test func test_distance_shortRange_exceedsThreshold() {
        // Two points ~60km apart
        let home = Location(latitude: 10.762622, longitude: 106.660172)
        let farPoint = Location(latitude: 11.3, longitude: 106.660172)
        let distance = home.distance(to: farPoint) / 1000
        #expect(distance > 50)
    }

    @Test func test_equatable_sameLocations_areEqual() {
        let loc1 = Location(latitude: 10.0, longitude: 20.0, name: "A")
        let loc2 = Location(latitude: 10.0, longitude: 20.0, name: "A")
        #expect(loc1 == loc2)
    }
}
