import SwiftUI

struct CaptureMenuView: View {
    let isCameraAvailable: Bool
    let isVoiceAvailable: Bool
    let isGalleryAvailable: Bool

    var onCameraTap: () -> Void
    var onVoiceTap: () -> Void
    var onGalleryTap: () -> Void
    var onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 12) {
            // Handle indicator
            Capsule()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: 36, height: 4)
                .padding(.top, 4)

            if isCameraAvailable {
                CaptureOptionButton(
                    icon: "camera.fill",
                    title: "Camera",
                    subtitle: "Take a photo or video",
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
                    title: "Voice",
                    subtitle: "Record a voice note",
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
                    title: "Gallery",
                    subtitle: "Choose from your library",
                    color: BrandColors.categoryGreen,
                    action: onGalleryTap
                )
                .offset(y: appeared ? 0 : 24)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.12), value: appeared)
            }

            Button("Cancel", action: onDismiss)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.top, 4)
                .padding(.bottom, 4)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.18), value: appeared)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.regularMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 20, y: -4)
        )
        .padding(.horizontal, 16)
        .scaleEffect(appeared ? 1 : 0.85)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: appeared)
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
