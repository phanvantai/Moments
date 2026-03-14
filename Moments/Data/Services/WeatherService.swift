import WeatherKit
import CoreLocation

final class WeatherService: WeatherServiceProtocol, @unchecked Sendable {
    private let weatherService = WeatherKit.WeatherService.shared

    func fetchWeather(latitude: Double, longitude: Double) async -> Weather? {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        do {
            let weather = try await weatherService.weather(for: location)
            let current = weather.currentWeather
            return Weather(
                condition: current.condition.description,
                temperature: current.temperature.converted(to: .celsius).value,
                icon: mapConditionToSFSymbol(current.condition)
            )
        } catch {
            return nil
        }
    }

    private func mapConditionToSFSymbol(_ condition: WeatherKit.WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "sun.max.fill"
        case .mostlyClear:
            return "sun.min.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .mostlyCloudy:
            return "cloud.fill"
        case .cloudy:
            return "smoke.fill"
        case .rain, .heavyRain:
            return "cloud.rain.fill"
        case .drizzle:
            return "cloud.drizzle.fill"
        case .snow, .heavySnow:
            return "cloud.snow.fill"
        case .thunderstorms:
            return "cloud.bolt.rain.fill"
        case .windy:
            return "wind"
        case .foggy:
            return "cloud.fog.fill"
        case .haze:
            return "sun.haze.fill"
        case .hot:
            return "thermometer.sun.fill"
        case .frigid:
            return "thermometer.snowflake"
        default:
            return "cloud.fill"
        }
    }
}
