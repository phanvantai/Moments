import SwiftUI

struct GridView: View {
    let moments: [Moment]
    let onMomentTap: (Moment) -> Void
    let onDeleteRequest: (UUID) -> Void
    let onRefresh: () async -> Void

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

    private var groupedMoments: [(String, [Moment])] {
        let calendar = Calendar.current
        let now = Date()

        var groups: [(String, [Moment])] = []
        var currentLabel = ""
        var currentGroup: [Moment] = []

        for moment in moments {
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
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
                  date >= weekAgo {
            return "This Week"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
    }

    // MARK: - Grid Content

    private var gridContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(Array(groupedMoments.enumerated()), id: \.offset) { _, section in
                    let (label, sectionMoments) = section

                    Section {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(sectionMoments) { moment in
                                GridCardView(viewModel: GridCardViewModel(moment: moment))
                                    .onTapGesture { onMomentTap(moment) }
                                    .scaleEffect(appearedCards.contains(moment.id) ? 1.0 : 0.85)
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
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.85)),
                                        removal: .opacity.combined(with: .scale(scale: 0.8))
                                    ))
                            }
                        }
                    } header: {
                        Text(label)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .refreshable {
            await onRefresh()
        }
    }
}
