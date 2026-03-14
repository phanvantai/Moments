import SwiftUI

struct TimelineNodeView: View {
    let viewModel: TimelineNodeViewModel
    let onTap: () -> Void

    @State private var thumbnailImage: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isTopAligned {
                contentCard
                connector
                circleNode
            } else {
                circleNode
                connector
                contentCard
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .task {
            if let path = viewModel.thumbnailPath {
                thumbnailImage = await ThumbnailCache.shared.loadThumbnail(for: path)
            }
        }
    }

    // MARK: - Circle Node

    private var circleNode: some View {
        ZStack {
            Circle()
                .fill(viewModel.categoryColor.opacity(0.2))
                .frame(width: 28, height: 28)

            Circle()
                .fill(viewModel.categoryColor)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(Color(.systemBackground), lineWidth: 2)
                )
                .shadow(color: viewModel.categoryColor.opacity(0.25), radius: 3, y: 1)
        }
    }

    // MARK: - Connector

    private var connector: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [viewModel.categoryColor.opacity(0.35), viewModel.categoryColor.opacity(0.1)],
                    startPoint: viewModel.isTopAligned ? .top : .bottom,
                    endPoint: viewModel.isTopAligned ? .bottom : .top
                )
            )
            .frame(width: 2, height: 20)
    }

    // MARK: - Content Card

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let image = thumbnailImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Text(viewModel.displayTitle)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .lineLimit(2)
                .foregroundStyle(.primary)

            Text(viewModel.createdAt, style: .relative)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(BrandColors.textSecondary)

            mediaBadges
        }
        .padding(10)
        .frame(width: 170)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
        .shadow(color: viewModel.categoryColor.opacity(0.08), radius: 3, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(viewModel.categoryColor.opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Media Badges

    private var mediaBadges: some View {
        HStack(spacing: 6) {
            if viewModel.hasPhotoBadge {
                badgeIcon("photo", color: BrandColors.categoryBlue)
            }
            if viewModel.hasVideoBadge {
                badgeIcon("video", color: BrandColors.categoryPurple)
            }
            if viewModel.hasVoiceBadge {
                badgeIcon("mic", color: BrandColors.categoryRed)
            }
        }
    }

    private func badgeIcon(_ name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 9, weight: .medium))
            .foregroundStyle(color.opacity(0.7))
    }
}
