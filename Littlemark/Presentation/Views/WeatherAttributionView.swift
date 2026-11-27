import SwiftUI

/// Apple Weather mark + "Other data sources" link, required by the WeatherKit terms.
struct WeatherAttributionView: View {
    let attribution: WeatherAttribution
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 8) {
            AsyncImage(url: colorScheme == .dark ? attribution.darkMarkURL : attribution.lightMarkURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Text(String(localized: "weather.attribution.mark", bundle: LanguageManager.shared.bundle))
                    .font(.system(.caption2, design: .rounded, weight: .medium))
            }
            .frame(height: 12)
            .accessibilityLabel(String(localized: "weather.attribution.mark", bundle: LanguageManager.shared.bundle))

            Link(String(localized: "weather.attribution.legal", bundle: LanguageManager.shared.bundle),
                 destination: attribution.legalPageURL)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(BrandColors.textSecondary)
        }
    }
}
