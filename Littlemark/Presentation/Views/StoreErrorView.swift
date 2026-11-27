import SwiftUI

struct StoreErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "externaldrive.badge.exclamationmark")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(BrandColors.accent.opacity(0.7))

            VStack(spacing: 8) {
                Text(String(localized: "store.error.title", bundle: LanguageManager.shared.bundle))
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(String(localized: "store.error.message", bundle: LanguageManager.shared.bundle))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(BrandColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            Button(action: onRetry) {
                Text(String(localized: "store.error.retry", bundle: LanguageManager.shared.bundle))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(BrandColors.accent)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
