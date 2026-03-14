import SwiftUI

struct GridView: View {
    let moments: [Moment]
    let onMomentTap: (Moment) -> Void
    let onDelete: (UUID) -> Void

    @State private var appearedCards: Set<UUID> = []

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        if moments.isEmpty {
            emptyState
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        } else {
            gridContent
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("📸")
                .font(.system(size: 64))
            Text("No moments yet")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
            Text("Tap  +  to capture your first moment")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Grid Content

    private var gridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(moments.enumerated()), id: \.element.id) { index, moment in
                    GridCardView(viewModel: GridCardViewModel(moment: moment))
                        .onTapGesture { onMomentTap(moment) }
                        .scaleEffect(appearedCards.contains(moment.id) ? 1.0 : 0.85)
                        .opacity(appearedCards.contains(moment.id) ? 1.0 : 0)
                        .onAppear {
                            let animation = Animation.spring(response: 0.4, dampingFraction: 0.75)
                                .delay(Double(index) * 0.05)
                            withAnimation(animation) {
                                appearedCards.insert(moment.id)
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    onDelete(moment.id)
                                }
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
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
