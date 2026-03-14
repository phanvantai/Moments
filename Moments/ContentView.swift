import SwiftUI

struct ContentView: View {
    let container: DependencyContainer

    @State private var showCreateMoment = false
    @State private var selectedMoment: Moment?
    @State private var timelineViewModel: TimelineViewModel?
    @State private var createMomentViewModel: CreateMomentViewModel?
    @State private var fabScale: CGFloat = 1.0
    @State private var fabRotation: Double = 0
    @State private var momentToDelete: UUID?
    @Namespace private var animationNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                if let vm = timelineViewModel {
                    mainContent(vm: vm)
                        .transition(.opacity)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // FAB Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        fabButton
                            .padding(.trailing, 24)
                            .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Moments")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if let vm = timelineViewModel {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            HapticManager.viewModeToggle()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                vm.toggleViewMode()
                            }
                        } label: {
                            Image(systemName: vm.viewMode == .timeline
                                  ? "square.grid.2x2"
                                  : "timeline.selection")
                                .font(.body)
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
                }
            }
            .confirmationDialog(
                "Delete this moment?",
                isPresented: Binding(
                    get: { momentToDelete != nil },
                    set: { if !$0 { momentToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let id = momentToDelete {
                        HapticManager.deleteWarning()
                        Task {
                            await timelineViewModel?.deleteMoment(id: id)
                        }
                    }
                    momentToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    momentToDelete = nil
                }
            } message: {
                Text("This will permanently delete the moment and all its media.")
            }
        }
        .fullScreenCover(isPresented: $showCreateMoment) {
            if let vm = createMomentViewModel {
                CreateMomentView(
                    viewModel: vm,
                    onDismiss: {
                        showCreateMoment = false
                        createMomentViewModel = nil
                    },
                    onSaved: {
                        showCreateMoment = false
                        createMomentViewModel = nil
                        Task {
                            await timelineViewModel?.loadMoments()
                        }
                    }
                )
            }
        }
        .sheet(item: $selectedMoment) { moment in
            MomentDetailView(
                viewModel: MomentDetailViewModel(moment: moment),
                onDismiss: { selectedMoment = nil }
            )
        }
        .task {
            let vm = container.makeTimelineViewModel()
            timelineViewModel = vm
            await vm.loadMoments()
        }
    }

    // MARK: - FAB Button

    private var fabButton: some View {
        Button {
            HapticManager.fabTap()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                fabScale = 0.8
                fabRotation = 90
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    fabScale = 1.0
                    fabRotation = 0
                }
                createMomentViewModel = container.makeCreateMomentViewModel()
                showCreateMoment = true
            }
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Circle().fill(BrandColors.fabGradient))
                .shadow(color: BrandColors.accent.opacity(0.3), radius: 8, y: 4)
                .scaleEffect(fabScale)
                .rotationEffect(.degrees(fabRotation))
        }
        .accessibilityLabel("Create new moment")
    }

    // MARK: - Main Content

    @ViewBuilder
    private func mainContent(vm: TimelineViewModel) -> some View {
        if vm.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = vm.errorMessage {
            errorState(message: error, vm: vm)
        } else {
            switch vm.viewMode {
            case .timeline:
                TimelineView(
                    moments: vm.moments,
                    onMomentTap: { moment in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedMoment = moment
                        }
                    },
                    onDeleteRequest: { id in
                        momentToDelete = id
                    },
                    onRefresh: {
                        await vm.loadMoments()
                    }
                )
                .transition(.move(edge: .leading).combined(with: .opacity))
            case .grid:
                GridView(
                    moments: vm.moments,
                    onMomentTap: { moment in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedMoment = moment
                        }
                    },
                    onDeleteRequest: { id in
                        momentToDelete = id
                    },
                    onRefresh: {
                        await vm.loadMoments()
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }

    // MARK: - Error State

    private func errorState(message: String, vm: TimelineViewModel) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text("Something went wrong")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
            Text(message)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                Task { await vm.loadMoments() }
            } label: {
                Text("Try Again")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(.blue))
                    .foregroundStyle(.white)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
