import Foundation

/// Apple Weather mark and legal link that must be shown wherever WeatherKit data appears.
struct WeatherAttribution: Equatable, Sendable {
    let lightMarkURL: URL
    let darkMarkURL: URL
    let legalPageURL: URL
}
