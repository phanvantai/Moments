import SwiftUI

struct TimelineNodeView: View {
    let viewModel: TimelineNodeViewModel
    let onTap: () -> Void

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
        .onTapGesture { onTap() }
    }

    // MARK: - Circle Node

    private var circleNode: some View {
        Circle()
            .fill(viewModel.categoryColor)
            .frame(width: 16, height: 16)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: viewModel.categoryColor.opacity(0.3), radius: 4, y: 2)
    }

    // MARK: - Connector

    private var connector: some View {
        Rectangle()
            .fill(viewModel.categoryColor.opacity(0.3))
            .frame(width: 2, height: 24)
    }

    // MARK: - Content Card

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let emoji = viewModel.categoryEmoji {
                Text(emoji)
                    .font(.title3)
            }

            Text(viewModel.displayTitle)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .lineLimit(2)
                .foregroundStyle(.primary)

            Text(viewModel.createdAt, style: .date)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.secondary)

            mediaBadges
        }
        .padding(10)
        .frame(width: 120)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(viewModel.categoryColor.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Media Badges

    private var mediaBadges: some View {
        HStack(spacing: 4) {
            if viewModel.hasPhotoBadge {
                badgeIcon("photo")
            }
            if viewModel.hasVideoBadge {
                badgeIcon("video")
            }
            if viewModel.hasVoiceBadge {
                badgeIcon("mic")
            }
        }
    }

    private func badgeIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 10))
            .foregroundStyle(.secondary)
    }
}
