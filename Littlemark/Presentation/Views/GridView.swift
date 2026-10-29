import SwiftUI

struct GridView: View {
    let moments: [Moment]
    let isLoadingMore: Bool
    let hasMoreOlderMoments: Bool
    let onMomentTap: (Moment) -> Void
    let onDeleteRequest: (UUID) -> Void
    let onRefresh: () async -> Void
    let onLoadMore: () async -> Void

    @State private var appearedCards: Set<UUID> = []

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        if moments.isEmpty {
            EmptyMomentsView()
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        } else {
            gridContent
        }
    }

    // MARK: - Grouped Moments

    /// `moments` is oldest-first: older pages load at the top, newest moments sit at the bottom.
    private var sections: [MomentGridSections.Section] {
        let bundle = LanguageManager.shared.bundle
        return MomentGridSections.make(
            from: moments,
            locale: Locale(identifier: LanguageManager.shared.currentLanguage.rawValue),
            labels: .init(
                today: String(localized: "today", bundle: bundle),
                yesterday: String(localized: "yesterday", bundle: bundle),
                thisWeek: String(localized: "this.week", bundle: bundle)
            )
        )
    }

    // MARK: - Grid Content

    private var gridContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    // Load-more indicator at the top (older content)
                    if hasMoreOlderMoments {
                        loadMoreIndicator
                            .onAppear {
                                // Keep the first visible card in place after older moments are inserted above it
                                let anchorID = moments.first?.id
                                Task {
                                    await onLoadMore()
                                    if let anchorID {
                                        proxy.scrollTo(anchorID, anchor: .top)
                                    }
                                }
                            }
                    }

                    ForEach(sections) { section in
                        Section {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(section.moments) { moment in
                                    GridCardView(viewModel: GridCardViewModel(moment: moment))
                                        .id(moment.id)
                                        .onTapGesture { onMomentTap(moment) }
                                        .scaleEffect(appearedCards.contains(moment.id) ? 1.0 : 0.9)
                                        .opacity(appearedCards.contains(moment.id) ? 1.0 : 0)
                                        .onAppear {
                                            let animation = Animation.spring(response: 0.4, dampingFraction: 0.75)
                                                .delay(0.05)
                                            withAnimation(animation) {
                                                appearedCards.insert(moment.id)
                                            }
                                        }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                onDeleteRequest(moment.id)
                                            } label: {
                                                Label(String(localized: "delete", bundle: LanguageManager.shared.bundle), systemImage: "trash")
                                            }
                                        }
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
                                            removal: .opacity.combined(with: .scale(scale: 0.85))
                                        ))
                                }
                            }
                        } header: {
                            Text(section.title)
                                .font(.system(.footnote, design: .rounded, weight: .semibold))
                                .foregroundStyle(BrandColors.sectionHeader)
                                .textCase(.uppercase)
                                .tracking(0.5)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .refreshable {
                await onRefresh()
            }
            .onAppear {
                // Start at the bottom (newest moments) like iOS Photos
                if let newestMoment = moments.last {
                    proxy.scrollTo(newestMoment.id, anchor: .bottom)
                }
            }
            .onChange(of: moments.last?.id) {
                // Only follow a newly added moment; loading older pages must not jump to the bottom
                if let newestMoment = moments.last {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        proxy.scrollTo(newestMoment.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Load More Indicator

    private var loadMoreIndicator: some View {
        HStack {
            Spacer()
            if isLoadingMore {
                ProgressView()
                    .tint(BrandColors.accent)
            }
            Spacer()
        }
        .frame(height: 44)
    }
}
