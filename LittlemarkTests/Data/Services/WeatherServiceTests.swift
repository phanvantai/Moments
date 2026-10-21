import Testing
import Foundation
@testable import Littlemark

struct WeatherServiceTests {
    // Note: WeatherService wraps WeatherKit which requires network + entitlement.
    // We test via the protocol mock for unit tests.

    @Test func test_mock_validLocation_returnsWeather() async {
        let mock = MockWeatherService()
        mock.weatherToReturn = Weather(
            condition: "Sunny",
            temperature: 32.0,
            icon: "sun.max.fill"
        )

        let result = await mock.fetchWeather(latitude: 10.762622, longitude: 106.660172)

        #expect(result != nil)
        #expect(result?.condition == "Sunny")
        #expect(result?.temperature == 32.0)
        #expect(result?.icon == "sun.max.fill")
        #expect(mock.fetchWeatherCallCount == 1)
        #expect(mock.lastLatitude == 10.762622)
        #expect(mock.lastLongitude == 106.660172)
    }

    @Test func test_mock_noNetwork_returnsNil() async {
        let mock = MockWeatherService()
        mock.weatherToReturn = nil

        let result = await mock.fetchWeather(latitude: 10.0, longitude: 106.0)

        #expect(result == nil)
        #expect(mock.fetchWeatherCallCount == 1)
    }

    @Test func test_mock_noLocation_returnsNil() async {
        let mock = MockWeatherService()
        mock.weatherToReturn = nil

        let result = await mock.fetchWeather(latitude: 0, longitude: 0)

        #expect(result == nil)
    }

    @Test func test_mock_differentConditions() async {
        let mock = MockWeatherService()
        mock.weatherToReturn = Weather(
            condition: "Rainy",
            temperature: 25.0,
            icon: "cloud.rain.fill"
        )

        let result = await mock.fetchWeather(latitude: 10.0, longitude: 106.0)

        #expect(result?.condition == "Rainy")
        #expect(result?.temperature == 25.0)
        #expect(result?.icon == "cloud.rain.fill")
    }

    @Test func test_mock_tracksCapturedArguments() async {
        let mock = MockWeatherService()
        mock.weatherToReturn = Weather(condition: "Clear", temperature: 30.0, icon: "sun.max.fill")

        _ = await mock.fetchWeather(latitude: 21.028511, longitude: 105.804817)

        #expect(mock.lastLatitude == 21.028511)
        #expect(mock.lastLongitude == 105.804817)
    }
}
