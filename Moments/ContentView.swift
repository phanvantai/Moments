import SwiftUI

struct ContentView: View {
    let container: DependencyContainer

    @State private var showCreateMoment = false
    @State private var selectedMoment: Moment?
    @State private var timelineViewModel: TimelineViewModel?
    @State private var createMomentViewModel: CreateMomentViewModel?
    @Namespace private var animationNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                if let vm = timelineViewModel {
                    mainContent(vm: vm)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // FAB Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            createMomentViewModel = container.makeCreateMomentViewModel()
                            showCreateMoment = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(Circle().fill(.blue))
                                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                        }
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
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                vm.toggleViewMode()
                            }
                        } label: {
                            Image(systemName: vm.viewMode == .timeline
                                  ? "square.grid.2x2"
                                  : "timeline.selection")
                                .font(.body)
                        }
                    }
                }
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

    // MARK: - Main Content

    @ViewBuilder
    private func mainContent(vm: TimelineViewModel) -> some View {
        if vm.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            switch vm.viewMode {
            case .timeline:
                TimelineView(
                    moments: vm.moments,
                    onMomentTap: { moment in
                        selectedMoment = moment
                    },
                    onDelete: { id in
                        Task { await vm.deleteMoment(id: id) }
                    }
                )
            case .grid:
                GridView(
                    moments: vm.moments,
                    onMomentTap: { moment in
                        selectedMoment = moment
                    },
                    onDelete: { id in
                        Task { await vm.deleteMoment(id: id) }
                    }
                )
            }
        }
    }
}
