import SwiftUI

struct GridCardView: View {
    let viewModel: GridCardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            thumbnailView
                .frame(height: 140)
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.displayTitle)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                Text(viewModel.createdAt, style: .date)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)

                categoryBadges
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Thumbnail

    @ViewBuilder
    private var thumbnailView: some View {
        if let url = viewModel.thumbnailURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderView
                default:
                    placeholderView
                }
            }
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [viewModel.categoryColor.opacity(0.2), viewModel.categoryColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            if let emoji = viewModel.placeholderEmoji {
                Text(emoji)
                    .font(.system(size: 32))
            } else if viewModel.isVoiceOnly {
                Image(systemName: "mic.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Category Badges

    private var categoryBadges: some View {
        HStack(spacing: 4) {
            ForEach(viewModel.categoryBadges) { category in
                Text(category.emoji)
                    .font(.system(size: 12))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.primary.opacity(0.05))
                    )
            }
        }
    }
}
