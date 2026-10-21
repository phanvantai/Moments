import Foundation

enum DurationFormatter {
    /// Formats a TimeInterval as "M:SS" (e.g., "2:05")
    static func shortFormat(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Formats a TimeInterval as "MM:SS" (e.g., "02:05")
    static func paddedFormat(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
