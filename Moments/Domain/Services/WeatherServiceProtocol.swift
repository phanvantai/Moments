import Foundation

protocol WeatherServiceProtocol: Sendable {
    func fetchWeather(latitude: Double, longitude: Double) async -> Weather?
}
