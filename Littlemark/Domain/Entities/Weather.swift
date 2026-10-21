import Foundation

struct Weather: Equatable, Hashable, Sendable {
    let condition: String
    let temperature: Double
    let icon: String

    init(condition: String, temperature: Double, icon: String) {
        self.condition = condition
        self.temperature = temperature
        self.icon = icon
    }
}
