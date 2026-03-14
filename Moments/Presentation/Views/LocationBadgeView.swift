import SwiftUI

struct LocationBadgeView: View {
    let location: Location
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(BrandColors.categoryRed)
            Text(location.name ?? locationCoordinateText)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .lineLimit(1)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "remove.location"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(BrandColors.categoryRed.opacity(0.10))
        )
        .accessibilityLabel(String(localized: "location.label \(location.name ?? locationCoordinateText)"))
    }

    private var locationCoordinateText: String {
        String(format: "%.4f, %.4f", location.latitude, location.longitude)
    }
}
