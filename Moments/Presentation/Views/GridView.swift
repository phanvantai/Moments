import SwiftUI

struct GridView: View {
    let moments: [Moment]
    let onMomentTap: (Moment) -> Void
    let onDelete: (UUID) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        if moments.isEmpty {
            emptyState
        } else {
            gridContent
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No moments yet")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Tap + to capture your first moment")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Grid Content

    private var gridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(moments) { moment in
                    GridCardView(viewModel: GridCardViewModel(moment: moment))
                        .onTapGesture { onMomentTap(moment) }
                        .contextMenu {
                            Button(role: .destructive) {
                                onDelete(moment.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
