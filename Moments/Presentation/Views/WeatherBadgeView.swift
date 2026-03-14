import SwiftUI

struct WeatherBadgeView: View {
    let weather: Weather

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: weather.icon)
                .font(.system(size: 16))
                .foregroundStyle(BrandColors.categoryOrange)
            Text("\(Int(weather.temperature))°C")
                .font(.system(.caption, design: .rounded, weight: .medium))
            Text(weather.condition)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(BrandColors.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(BrandColors.categoryOrange.opacity(0.10))
        )
        .accessibilityLabel("\(weather.condition), \(Int(weather.temperature)) degrees")
    }
}
