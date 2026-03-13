import Testing
import Foundation
@testable import Moments

struct WeatherTests {

    @Test func test_init_storesCorrectValues() {
        let weather = Weather(condition: "Sunny", temperature: 32.0, icon: "sun.max")

        #expect(weather.condition == "Sunny")
        #expect(weather.temperature == 32.0)
        #expect(weather.icon == "sun.max")
    }

    @Test func test_equatable_sameWeather_areEqual() {
        let w1 = Weather(condition: "Rainy", temperature: 25.0, icon: "cloud.rain")
        let w2 = Weather(condition: "Rainy", temperature: 25.0, icon: "cloud.rain")
        #expect(w1 == w2)
    }

    @Test func test_equatable_differentWeather_areNotEqual() {
        let w1 = Weather(condition: "Sunny", temperature: 32.0, icon: "sun.max")
        let w2 = Weather(condition: "Rainy", temperature: 25.0, icon: "cloud.rain")
        #expect(w1 != w2)
    }
}
