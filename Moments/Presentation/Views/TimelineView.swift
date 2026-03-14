import SwiftUI

struct TimelineView: View {
    let moments: [Moment]
    let onMomentTap: (Moment) -> Void
    let onDelete: (UUID) -> Void

    @State private var appearedNodes: Set<UUID> = []

    var body: some View {
        if moments.isEmpty {
            emptyState
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        } else {
            timelineContent
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

    // MARK: - Timeline Content

    private var timelineContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack(alignment: .center) {
                // Horizontal line
                timelineLine

                // Nodes
                HStack(spacing: 20) {
                    ForEach(Array(moments.enumerated()), id: \.element.id) { index, moment in
                        TimelineNodeView(
                            viewModel: TimelineNodeViewModel(moment: moment, index: index),
                            onTap: { onMomentTap(moment) }
                        )
                        .opacity(appearedNodes.contains(moment.id) ? 1 : 0)
                        .offset(y: appearedNodes.contains(moment.id) ? 0 : 20)
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    onDelete(moment.id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .onAppear {
                            let animation = Animation.spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(index) * 0.08)
                            withAnimation(animation) {
                                appearedNodes.insert(moment.id)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.8)),
                            removal: .opacity.combined(with: .offset(y: 40))
                        ))
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Timeline Line

    private var timelineLine: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.1), .blue.opacity(0.3), .blue.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
