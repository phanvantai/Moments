import SwiftUI

struct TimelineView: View {
    let moments: [Moment]
    let onMomentTap: (Moment) -> Void
    let onDeleteRequest: (UUID) -> Void
    let onRefresh: () async -> Void

    @State private var appearedNodes: Set<UUID> = []

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
                                onDeleteRequest(moment.id)
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
                .fill(BrandColors.timelineGradient)
                .frame(height: 2)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
