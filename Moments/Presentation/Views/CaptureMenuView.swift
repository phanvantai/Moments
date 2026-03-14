import SwiftUI

struct CaptureMenuView: View {
    let isCameraAvailable: Bool
    let isVoiceAvailable: Bool
    let isGalleryAvailable: Bool

    var onCameraTap: () -> Void
    var onVoiceTap: () -> Void
    var onGalleryTap: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            if isCameraAvailable {
                CaptureOptionButton(
                    icon: "camera.fill",
                    title: "Camera",
                    subtitle: "Take a photo or video",
                    color: .blue,
                    action: onCameraTap
                )
            }

            if isVoiceAvailable {
                CaptureOptionButton(
                    icon: "mic.fill",
                    title: "Voice",
                    subtitle: "Record a voice note",
                    color: .red,
                    action: onVoiceTap
                )
            }

            if isGalleryAvailable {
                CaptureOptionButton(
                    icon: "photo.on.rectangle.angled",
                    title: "Gallery",
                    subtitle: "Choose from your library",
                    color: .green,
                    action: onGalleryTap
                )
            }

            Button("Cancel", action: onDismiss)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.regularMaterial)
        )
        .padding(.horizontal, 24)
    }
}

private struct CaptureOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(color))

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
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
            )
        }
        .buttonStyle(.plain)
    }
}
