import SwiftUI

struct ContentView: View {
    let container: DependencyContainer

    @State private var showCreateMoment = false
    @State private var timelineViewModel: TimelineViewModel?
    @State private var createMomentViewModel: CreateMomentViewModel?

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Spacer()

                Text("Moments")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))

                Text("Every moment matters.")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

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
                    }
                )
            }
        }
        .task {
            timelineViewModel = container.makeTimelineViewModel()
        }
    }
}
