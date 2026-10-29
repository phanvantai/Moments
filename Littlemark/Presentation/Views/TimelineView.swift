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
                HStack(alignment: .center, spacing: nodeSpacing) {
                    // Load-more indicator at the leading edge
                    if hasMoreOlderMoments {
                        loadMoreIndicator
                            .onAppear {
                                // Keep the first visible node in place after older moments are inserted before it
                                let anchorID = moments.first?.id
                                Task {
                                    await onLoadMore()
                                    if let anchorID {
                                        proxy.scrollTo(anchorID, anchor: .leading)
                                    }
                                }
                            }
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
                            let animation = Animation.spring(response: 0.5, dampingFraction: 0.75)
                                .delay(Double(index) * 0.06)
                            withAnimation(animation) {
                                appearedNodes.insert(moment.id)
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
            .onAppear {
                if let lastMoment = moments.last {
                    proxy.scrollTo(lastMoment.id, anchor: .trailing)
                }
            }
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

    private var loadMoreIndicator: some View {
        VStack {
            if isLoadingMore {
                ProgressView()
                    .tint(BrandColors.accent)
            }
        }
        .frame(width: 44, height: 44)
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
