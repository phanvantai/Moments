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

    func fetchWeather(latitude: Double, longitude: Double, date: Date) async -> Weather? {
        let calendar = Calendar.current

        // If today, use current weather
        if calendar.isDateInToday(date) {
            return await fetchWeather(latitude: latitude, longitude: longitude)
        }

        // WeatherKit historical data available from Aug 1, 2021
        guard let cutoffDate = calendar.date(from: DateComponents(year: 2021, month: 8, day: 1)),
              date >= cutoffDate else {
            return nil
        }

        let location = CLLocation(latitude: latitude, longitude: longitude)
        let startOfHour = calendar.dateInterval(of: .hour, for: date)?.start ?? date
        let endOfHour = startOfHour.addingTimeInterval(3600)

        do {
            let forecast = try await weatherService.weather(
                for: location,
                including: .hourly(startDate: startOfHour, endDate: endOfHour)
            )
            guard let hourWeather = forecast.forecast.first else {
                return nil
            }
            return Weather(
                condition: hourWeather.condition.description,
                temperature: hourWeather.temperature.converted(to: .celsius).value,
                icon: mapConditionToSFSymbol(hourWeather.condition)
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
