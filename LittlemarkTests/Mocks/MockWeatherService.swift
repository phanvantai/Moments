import Foundation
@testable import Littlemark

final class MockWeatherService: WeatherServiceProtocol, @unchecked Sendable {
    var fetchWeatherCallCount = 0
    var lastLatitude: Double?
    var lastLongitude: Double?
    var lastDate: Date?
    var weatherToReturn: Weather?
    var fetchAttributionCallCount = 0
    var attributionToReturn: WeatherAttribution? = WeatherAttribution(
        lightMarkURL: URL(string: "https://example.com/mark-light.png")!,
        darkMarkURL: URL(string: "https://example.com/mark-dark.png")!,
        legalPageURL: URL(string: "https://example.com/legal")!
    )

    func fetchWeather(latitude: Double, longitude: Double) async -> Weather? {
        fetchWeatherCallCount += 1
        lastLatitude = latitude
        lastLongitude = longitude
        lastDate = nil
        return weatherToReturn
    }

    func fetchWeather(latitude: Double, longitude: Double, date: Date) async -> Weather? {
        fetchWeatherCallCount += 1
        lastLatitude = latitude
        lastLongitude = longitude
        lastDate = date
        return weatherToReturn
    }

    func fetchAttribution() async -> WeatherAttribution? {
        fetchAttributionCallCount += 1
        return attributionToReturn
    }
}
