import Testing
import Foundation
@testable import Littlemark

struct LocationServiceTests {
    // Note: LocationService wraps CLLocationManager which requires device/simulator.
    // We test via the protocol mock for unit tests.
    // Integration-level tests for the real LocationService are run on device.

    @Test func test_mock_authorized_success_returnsLocation() async {
        let mock = MockLocationService()
        mock.locationToReturn = Location(
            latitude: 10.762622,
            longitude: 106.660172,
            name: "Ho Chi Minh City",
            address: "123 Nguyen Hue, District 1",
            placeType: "city"
        )

        let result = await mock.getCurrentLocation()

        #expect(result != nil)
        #expect(result?.latitude == 10.762622)
        #expect(result?.longitude == 106.660172)
        #expect(result?.name == "Ho Chi Minh City")
        #expect(result?.address == "123 Nguyen Hue, District 1")
        #expect(result?.placeType == "city")
        #expect(mock.getCurrentLocationCallCount == 1)
    }

    @Test func test_mock_denied_returnsNil() async {
        let mock = MockLocationService()
        mock.locationToReturn = nil

        let result = await mock.getCurrentLocation()

        #expect(result == nil)
        #expect(mock.getCurrentLocationCallCount == 1)
    }

    @Test func test_mock_geocodeSuccess_hasNameAddressPlaceType() async {
        let mock = MockLocationService()
        mock.locationToReturn = Location(
            latitude: 10.0,
            longitude: 106.0,
            name: "Central Park",
            address: "123 Park Ave",
            placeType: "park"
        )

        let result = await mock.getCurrentLocation()

        #expect(result?.name == "Central Park")
        #expect(result?.address == "123 Park Ave")
        #expect(result?.placeType == "park")
    }

    @Test func test_mock_geocodeFail_onlyLatLng() async {
        let mock = MockLocationService()
        mock.locationToReturn = Location(
            latitude: 10.0,
            longitude: 106.0
        )

        let result = await mock.getCurrentLocation()

        #expect(result != nil)
        #expect(result?.latitude == 10.0)
        #expect(result?.longitude == 106.0)
        #expect(result?.name == nil)
        #expect(result?.address == nil)
        #expect(result?.placeType == nil)
    }

    @Test func test_mock_multipleCallsTracked() async {
        let mock = MockLocationService()
        mock.locationToReturn = Location(latitude: 10.0, longitude: 106.0)

        _ = await mock.getCurrentLocation()
        _ = await mock.getCurrentLocation()

        #expect(mock.getCurrentLocationCallCount == 2)
    }
}
