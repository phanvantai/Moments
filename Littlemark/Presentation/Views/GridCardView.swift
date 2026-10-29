import SwiftUI

struct GridCardView: View {
    let viewModel: GridCardViewModel

    @State private var thumbnailImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail area
            thumbnailView
                .frame(height: 160)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    mediaBadgeOverlay
                }

            // Content area
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.displayTitle)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text(viewModel.createdAt, style: .relative)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(BrandColors.textSecondary)

                if !viewModel.categoryBadges.isEmpty {
                    categoryBadges
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
        .shadow(color: viewModel.categoryColor.opacity(0.08), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(BrandColors.cardBorder.opacity(0.5), lineWidth: 0.5)
        )
        .task {
            if let path = viewModel.thumbnailPath {
                thumbnailImage = await ThumbnailCache.shared.loadThumbnail(for: path)
            }
        }
    }

    // MARK: - Thumbnail

    @ViewBuilder
    private var thumbnailView: some View {
        if let image = thumbnailImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .transition(.opacity.animation(.easeOut(duration: 0.25)))
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            viewModel.categoryColor.opacity(0.15),
                            viewModel.categoryColor.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            if viewModel.isVoiceOnly {
                VStack(spacing: 6) {
                    Image(systemName: "waveform")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(viewModel.categoryColor.opacity(0.5))
                    Text(String(localized: "voice.note", bundle: LanguageManager.shared.bundle))
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(viewModel.categoryColor.opacity(0.4))
                }
            } else {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(viewModel.categoryColor.opacity(0.4))
            }
        }
    }

    // MARK: - Media Badge Overlay

    @ViewBuilder
    private var mediaBadgeOverlay: some View {
        if viewModel.hasVideoBadge || viewModel.hasVoiceBadge {
            HStack(spacing: 4) {
                if viewModel.hasVideoBadge {
                    Image(systemName: "video.fill")
                        .font(.system(size: 9, weight: .semibold))
                }
                if viewModel.hasVoiceBadge {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 9, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Capsule().fill(.black.opacity(0.45)))
            .padding(8)
        }
    }

    private var hasVideoBadge: Bool {
        viewModel.categoryBadges.isEmpty == false
    }

    // MARK: - Category Badges

    private var categoryBadges: some View {
        HStack(spacing: 4) {
            ForEach(viewModel.categoryBadges) { category in
                HStack(spacing: 2) {
                    Text(category.emoji)
                        .font(.caption2)
                    Text(MomentDisplayHelper.label(for: category))
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .lineLimit(1)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(MomentDisplayHelper.color(forCategoryKey: category.key).opacity(0.12))
                )
                .foregroundStyle(MomentDisplayHelper.color(forCategoryKey: category.key))
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
