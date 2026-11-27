import SwiftUI

struct CaptureMenuView: View {
    let isCameraAvailable: Bool
    let isVoiceAvailable: Bool
    let isGalleryAvailable: Bool

    var onCameraTap: () -> Void
    var onVoiceTap: () -> Void
    var onGalleryTap: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 12) {
            if isCameraAvailable {
                CaptureOptionButton(
                    icon: "camera.fill",
                    title: String(localized: "capture.camera", bundle: LanguageManager.shared.bundle),
                    subtitle: String(localized: "capture.camera.subtitle", bundle: LanguageManager.shared.bundle),
                    color: BrandColors.categoryBlue,
                    action: onCameraTap
                )
                .offset(y: appeared ? 0 : 24)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(0), value: appeared)
            }

            if isVoiceAvailable {
                CaptureOptionButton(
                    icon: "mic.fill",
                    title: String(localized: "capture.voice", bundle: LanguageManager.shared.bundle),
                    subtitle: String(localized: "capture.voice.subtitle", bundle: LanguageManager.shared.bundle),
                    color: BrandColors.categoryRed,
                    action: onVoiceTap
                )
                .offset(y: appeared ? 0 : 24)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.06), value: appeared)
            }

            if isGalleryAvailable {
                CaptureOptionButton(
                    icon: "photo.on.rectangle.angled",
                    title: String(localized: "capture.gallery", bundle: LanguageManager.shared.bundle),
                    subtitle: String(localized: "capture.gallery.subtitle", bundle: LanguageManager.shared.bundle),
                    color: BrandColors.categoryGreen,
                    action: onGalleryTap
                )
                .offset(y: appeared ? 0 : 24)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.12), value: appeared)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .onAppear {
            appeared = true
        }
    }
}

private struct CaptureOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(color.gradient)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.quaternary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
    }
}
