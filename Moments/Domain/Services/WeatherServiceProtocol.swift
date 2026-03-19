import Foundation

protocol WeatherServiceProtocol: Sendable {
    func fetchWeather(latitude: Double, longitude: Double) async -> Weather?
    func fetchWeather(latitude: Double, longitude: Double, date: Date) async -> Weather?
}
