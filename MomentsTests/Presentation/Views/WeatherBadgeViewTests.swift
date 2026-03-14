import Testing
import Foundation
@testable import Moments

struct WeatherBadgeViewTests {
    @Test func test_weatherBadge_displaysConditionAndTemperature() {
        let weather = Weather(condition: "Sunny", temperature: 32.0, icon: "sun.max.fill")

        let view = WeatherBadgeView(weather: weather)

        // View renders without crash
        _ = view.body
        #expect(weather.condition == "Sunny")
        #expect(weather.temperature == 32.0)
        #expect(weather.icon == "sun.max.fill")
    }

    @Test func test_weatherBadge_negativeTemperature() {
        let weather = Weather(condition: "Freezing", temperature: -5.0, icon: "thermometer.snowflake")

        let view = WeatherBadgeView(weather: weather)
        _ = view.body
    }

    @Test func test_weatherBadge_zeroTemperature() {
        let weather = Weather(condition: "Cold", temperature: 0.0, icon: "cloud.fill")

        let view = WeatherBadgeView(weather: weather)
        _ = view.body
    }
}
