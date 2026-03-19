import Foundation
@testable import Moments

final class MockWeatherService: WeatherServiceProtocol, @unchecked Sendable {
    var fetchWeatherCallCount = 0
    var lastLatitude: Double?
    var lastLongitude: Double?
    var lastDate: Date?
    var weatherToReturn: Weather?

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
}
