import SwiftUI

struct TimelineNodeView: View {
    let viewModel: TimelineNodeViewModel
    let onTap: () -> Void

    @State private var thumbnailImage: UIImage?

    // MARK: - Layout Constants

    private enum Layout {
        static let cardWidth: CGFloat = 176
        static let cardAreaHeight: CGFloat = 176
        static let connectorHeight: CGFloat = 28
        static let dateLabelHeight: CGFloat = 32
        static let circleOuter: CGFloat = 30
        static let circleInner: CGFloat = 14
        static let thumbnailHeight: CGFloat = 76
    }

    var body: some View {
        VStack(spacing: 0) {
            // Zone 1: Top card area
            Group {
                if viewModel.isTopAligned {
                    contentCard
                } else {
                    Color.clear
                }
            }
            .frame(height: Layout.cardAreaHeight, alignment: .bottom)

            // Zone 2: Top connector or date
            Group {
                if viewModel.isTopAligned {
                    connector
                } else {
                    dateLabel
                }
            }
            .frame(height: Layout.connectorHeight)

            // Zone 3: Circle node (timeline line drawn at parent level)
            circleNode
                .frame(height: Layout.circleOuter)

            // Zone 4: Bottom date or connector
            Group {
                if viewModel.isTopAligned {
                    dateLabel
                } else {
                    connector
                }
            }
            .frame(height: Layout.connectorHeight)

            // Zone 5: Bottom card area
            Group {
                if viewModel.isTopAligned {
                    Color.clear
                } else {
                    contentCard
                }
            }
            .frame(height: Layout.cardAreaHeight, alignment: .top)
        }
        .frame(width: Layout.cardWidth)
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
                .fill(viewModel.categoryColor.opacity(0.12))
                .frame(width: Layout.circleOuter, height: Layout.circleOuter)

            Circle()
                .fill(viewModel.categoryColor)
                .frame(width: Layout.circleInner, height: Layout.circleInner)
                .overlay(
                    Circle()
                        .stroke(Color(.systemBackground), lineWidth: 2.5)
                )
                .shadow(color: viewModel.categoryColor.opacity(0.35), radius: 4, y: 1)
        }
    }

    // MARK: - Connector

    private var connector: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(
                LinearGradient(
                    colors: [
                        viewModel.categoryColor.opacity(0.4),
                        viewModel.categoryColor.opacity(0.08)
                    ],
                    startPoint: viewModel.isTopAligned ? .top : .bottom,
                    endPoint: viewModel.isTopAligned ? .bottom : .top
                )
            )
            .frame(width: 2)
    }

    // MARK: - Date Label

    private var dateLabel: some View {
        VStack(spacing: 1) {
            Text(viewModel.formattedDate)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(BrandColors.textSecondary)

            Text(viewModel.formattedTime)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(BrandColors.textSecondary.opacity(0.7))
        }
    }

    // MARK: - Content Card

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail
            if let image = thumbnailImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: Layout.cardWidth - 16, height: Layout.thumbnailHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            // Subtle bottom gradient for depth
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .black.opacity(0.08)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )

                    // Category emoji pill
                    if let emoji = viewModel.categoryEmoji {
                        Text(emoji)
                            .font(.system(size: 11))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                            .padding(6)
                    }
                }
            } else {
                // Placeholder when no thumbnail
                RoundedRectangle(cornerRadius: 10)
                    .fill(viewModel.categoryColor.opacity(0.08))
                    .frame(width: Layout.cardWidth - 16, height: 40)
                    .overlay(
                        HStack(spacing: 4) {
                            if let emoji = viewModel.categoryEmoji {
                                Text(emoji)
                                    .font(.system(size: 13))
                            }
                            mediaBadges
                        }
                    )
            }

            // Title
            Text(viewModel.displayTitle)
                .font(.system(.footnote, design: .rounded, weight: .semibold))
                .lineLimit(2)
                .foregroundStyle(.primary)

            // Media badges (only when thumbnail exists, since placeholder already shows them)
            if thumbnailImage != nil {
                mediaBadges
            }
        }
        .padding(8)
        .frame(width: Layout.cardWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(viewModel.categoryColor.opacity(0.18), lineWidth: 0.5)
        )
        .shadow(color: viewModel.categoryColor.opacity(0.1), radius: 8, y: 3)
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
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
