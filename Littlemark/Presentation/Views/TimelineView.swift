import SwiftUI

struct TimelineView: View {
    let moments: [Moment]
    let isLoadingMore: Bool
    let hasMoreOlderMoments: Bool
    let onMomentTap: (Moment) -> Void
    let onDeleteRequest: (UUID) -> Void
    let onRefresh: () async -> Void
    let onLoadMore: () async -> Void

    @State private var appearedNodes: Set<UUID> = []

    private let nodeSpacing: CGFloat = 16

    var body: some View {
        if moments.isEmpty {
            EmptyMomentsView()
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        } else {
            timelineContent
        }
    }

    // MARK: - Timeline Content

    private var timelineContent: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: nodeSpacing) {
                    // Spinner at the leading edge while an older page loads
                    if hasMoreOlderMoments {
                        loadMoreIndicator
                    }

                    ForEach(Array(moments.enumerated()), id: \.element.id) { index, moment in
                        TimelineNodeView(
                            viewModel: TimelineNodeViewModel(moment: moment, index: index),
                            onTap: { onMomentTap(moment) }
                        )
                        .id(moment.id)
                        .opacity(appearedNodes.contains(moment.id) ? 1 : 0)
                        .offset(y: appearedNodes.contains(moment.id) ? 0 : (index % 2 == 0 ? -12 : 12))
                        .contextMenu {
                            Button(role: .destructive) {
                                onDeleteRequest(moment.id)
                            } label: {
                                Label(String(localized: "delete", bundle: LanguageManager.shared.bundle), systemImage: "trash")
                            }
                        }
                        .onAppear {
                            // Stagger from the newest node (where the timeline opens), capped so
                            // older pages don't wait seconds to appear
                            let distanceFromNewest = moments.count - 1 - index
                            let animation = Animation.spring(response: 0.5, dampingFraction: 0.75)
                                .delay(Double(min(distanceFromNewest, 5)) * 0.06)
                            withAnimation(animation) {
                                appearedNodes.insert(moment.id)
                            }
                            // The oldest loaded node coming into view loads the next page. Lazy stack
                            // items appear only when scrolled to, unlike a static load-more row.
                            if index == 0, hasMoreOlderMoments {
                                loadOlderMoments(proxy: proxy)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.85)),
                            removal: .opacity.combined(with: .offset(y: 30))
                        ))
                    }
                }
                .padding(.horizontal, UIScreen.main.bounds.width * 0.45)
                .background(alignment: .center) {
                    timelineLine
                }
            }
            // Open at the newest moment. Starting there, instead of scrolling on appear,
            // keeps the leading load-more node from firing before the user scrolls.
            .defaultScrollAnchor(.trailing)
            .onChange(of: moments.last?.id) {
                // Only follow a newly added moment; loading older pages must not jump to the end
                if let lastMoment = moments.last {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        proxy.scrollTo(lastMoment.id, anchor: .trailing)
                    }
                }
            }
        }
    }

    // MARK: - Load More Indicator

    /// Loads the next older page and keeps the node the user was looking at in place.
    private func loadOlderMoments(proxy: ScrollViewProxy) {
        let anchorID = moments.first?.id
        Task {
            await onLoadMore()
            if let anchorID {
                proxy.scrollTo(anchorID, anchor: .leading)
            }
        }
    }

    private var loadMoreIndicator: some View {
        // Color.clear, not an empty stack: an empty view may never get onAppear
        Color.clear
            .frame(width: 44, height: 44)
            .overlay {
                if isLoadingMore {
                    ProgressView()
                        .tint(BrandColors.accent)
                }
            }
    }

    // MARK: - Timeline Line

    private var timelineLine: some View {
        GeometryReader { geometry in
            let lineY = geometry.size.height / 2

            // Main timeline line with fade at edges
            RoundedRectangle(cornerRadius: 1.5)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: BrandColors.accent.opacity(0), location: 0),
                            .init(color: BrandColors.accent.opacity(0.22), location: 0.04),
                            .init(color: BrandColors.accent.opacity(0.22), location: 0.96),
                            .init(color: BrandColors.accent.opacity(0), location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2.5)
                .position(x: geometry.size.width / 2, y: lineY)

            // Subtle glow behind the line
            RoundedRectangle(cornerRadius: 6)
                .fill(BrandColors.accent.opacity(0.05))
                .frame(height: 14)
                .blur(radius: 5)
                .position(x: geometry.size.width / 2, y: lineY)
        }
    }
}
