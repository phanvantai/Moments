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
        VStack(spacing: 16) {
            if isCameraAvailable {
                CaptureOptionButton(
                    icon: "camera.fill",
                    title: "Camera",
                    subtitle: "Take a photo or video",
                    color: .blue,
                    action: onCameraTap
                )
                .offset(y: appeared ? 0 : 30)
                .opacity(appeared ? 1 : 0)
            }

            if isVoiceAvailable {
                CaptureOptionButton(
                    icon: "mic.fill",
                    title: "Voice",
                    subtitle: "Record a voice note",
                    color: .red,
                    action: onVoiceTap
                )
                .offset(y: appeared ? 0 : 30)
                .opacity(appeared ? 1 : 0)
            }

            if isGalleryAvailable {
                CaptureOptionButton(
                    icon: "photo.on.rectangle.angled",
                    title: "Gallery",
                    subtitle: "Choose from your library",
                    color: .green,
                    action: onGalleryTap
                )
                .offset(y: appeared ? 0 : 30)
                .opacity(appeared ? 1 : 0)
            }

            Button("Cancel", action: onDismiss)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.top, 8)
                .opacity(appeared ? 1 : 0)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.regularMaterial)
        )
        .padding(.horizontal, 24)
        .scaleEffect(appeared ? 1 : 0.8)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                appeared = true
            }
        }
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
