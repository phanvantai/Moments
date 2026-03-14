import SwiftUI

struct EmptyMomentsView: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Background decorative circles
                Circle()
                    .fill(BrandColors.accent.opacity(0.06))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(BrandColors.accent.opacity(0.10))
                    .frame(width: 110, height: 110)

                Image(systemName: "camera.on.rectangle")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(BrandColors.accent.opacity(0.6))
            }
            .scaleEffect(appeared ? 1.0 : 0.8)
            .opacity(appeared ? 1.0 : 0)

            VStack(spacing: 8) {
                Text(String(localized: "empty.title"))
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(String(localized: "empty.subtitle"))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(BrandColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .opacity(appeared ? 1.0 : 0)
            .offset(y: appeared ? 0 : 10)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) {
                appeared = true
            }
        }
    }
}
