import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            BrandColors.warmBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button(String(localized: "onboarding.skip", bundle: LanguageManager.shared.bundle)) { complete() }
                            .font(.system(.body, design: .rounded, weight: .medium))
                            .foregroundStyle(BrandColors.textSecondary)
                            .padding(.trailing, 24)
                            .padding(.top, 16)
                    } else {
                        Color.clear
                            .frame(height: 44)
                            .padding(.top, 16)
                    }
                }

                // Paged content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .tint(BrandColors.accent)

                // Bottom button area
                bottomArea
                    .padding(.horizontal, 40)
                    .padding(.bottom, 48)
            }
        }
        .onAppear { triggerAppearAnimation() }
        .onChange(of: currentPage) { _, _ in
            HapticManager.selection()
            appeared = false
            triggerAppearAnimation()
        }
    }

    // MARK: - Pages

    private var pages: [OnboardingPage] {
        OnboardingPage.allPages
    }

    // MARK: - Page View

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 28) {
            Spacer()

            // Decorative circles + icon
            ZStack {
                Circle()
                    .fill(page.iconColor.opacity(0.06))
                    .frame(width: 180, height: 180)

                Circle()
                    .fill(page.iconColor.opacity(0.12))
                    .frame(width: 120, height: 120)

                Image(systemName: page.icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(page.iconColor)
            }
            .scaleEffect(appeared ? 1.0 : 0.8)
            .opacity(appeared ? 1.0 : 0)
            .accessibilityHidden(true)

            // Text content
            VStack(spacing: 10) {
                Text(page.title)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)

                Text(page.subtitle)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(BrandColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .opacity(appeared ? 1.0 : 0)
            .offset(y: appeared ? 0 : 12)
            .accessibilityElement(children: .combine)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Bottom Area

    @ViewBuilder
    private var bottomArea: some View {
        if currentPage == pages.count - 1 {
            Button { complete() } label: {
                Text(String(localized: "onboarding.get.started", bundle: LanguageManager.shared.bundle))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(BrandColors.fabGradient))
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        } else {
            Color.clear
                .frame(height: 52)
        }
    }

    // MARK: - Helpers

    private func complete() {
        HapticManager.notification(.success)
        withAnimation(.easeOut(duration: 0.3)) {
            hasCompletedOnboarding = true
        }
    }

    private func triggerAppearAnimation() {
        let animation: Animation = reduceMotion
            ? .linear(duration: 0)
            : .spring(response: 0.5, dampingFraction: 0.75).delay(0.1)
        withAnimation(animation) {
            appeared = true
        }
    }
}

// MARK: - Page Data

private struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            icon: "camera.on.rectangle.fill",
            iconColor: BrandColors.accent,
            title: String(localized: "onboarding.capture.title", bundle: LanguageManager.shared.bundle),
            subtitle: String(localized: "onboarding.capture.subtitle", bundle: LanguageManager.shared.bundle)
        ),
        OnboardingPage(
            icon: "sparkles.rectangle.stack.fill",
            iconColor: BrandColors.categoryPurple,
            title: String(localized: "onboarding.categories.title", bundle: LanguageManager.shared.bundle),
            subtitle: String(localized: "onboarding.categories.subtitle", bundle: LanguageManager.shared.bundle)
        ),
        OnboardingPage(
            icon: "rectangle.grid.1x2.fill",
            iconColor: BrandColors.categoryBlue,
            title: String(localized: "onboarding.views.title", bundle: LanguageManager.shared.bundle),
            subtitle: String(localized: "onboarding.views.subtitle", bundle: LanguageManager.shared.bundle)
        ),
    ]
}
