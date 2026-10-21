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

    /// Moments reversed so oldest is first (top) and newest is last (bottom),
    /// matching iOS Photos library layout.
    private var reversedMoments: [Moment] {
        moments.reversed()
    }

    var body: some View {
        if moments.isEmpty {
            EmptyMomentsView()
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        } else {
            gridContent
        }
    }

    // MARK: - Grouped Moments

    private var groupedMoments: [(String, [Moment])] {
        let calendar = Calendar.current
        let now = Date()

        var groups: [(String, [Moment])] = []
        var currentLabel = ""
        var currentGroup: [Moment] = []

        for moment in reversedMoments {
            let label = sectionLabel(for: moment.createdAt, now: now, calendar: calendar)
            if label == currentLabel {
                currentGroup.append(moment)
            } else {
                if !currentGroup.isEmpty {
                    groups.append((currentLabel, currentGroup))
                }
                currentLabel = label
                currentGroup = [moment]
            }
        }
        if !currentGroup.isEmpty {
            groups.append((currentLabel, currentGroup))
        }

        return groups
    }

    private func sectionLabel(for date: Date, now: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(date) {
            return String(localized: "today", bundle: LanguageManager.shared.bundle)
        } else if calendar.isDateInYesterday(date) {
            return String(localized: "yesterday", bundle: LanguageManager.shared.bundle)
        } else if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
                  date >= weekAgo {
            return String(localized: "this.week", bundle: LanguageManager.shared.bundle)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
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
                                Task { await onLoadMore() }
                            }
                    }

                    ForEach(Array(groupedMoments.enumerated()), id: \.offset) { _, section in
                        let (label, sectionMoments) = section

                        Section {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(sectionMoments) { moment in
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
                            Text(label)
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
                // Auto-scroll to bottom (newest moments) like iOS Photos
                if let newestMoment = moments.first {
                    proxy.scrollTo(newestMoment.id, anchor: .bottom)
                }
            }
            .onChange(of: moments.count) {
                // Keep scrolled to newest when new moments are added
                if let newestMoment = moments.first {
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
