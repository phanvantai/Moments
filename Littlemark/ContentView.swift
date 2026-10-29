import SwiftUI
import UIKit

struct ContentView: View {
    let container: DependencyContainer

    @State private var showSettings = false
    @State private var selectedMoment: Moment?
    @State private var timelineViewModel: TimelineViewModel?
    @State private var createMomentViewModel: CreateMomentViewModel?
    @State private var showCaptureMenu = false
    @State private var fabScale: CGFloat = 1.0
    @State private var fabRotation: Double = 0
    @State private var momentToDelete: UUID?
    @State private var permissionDeniedType: String?
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
            .navigationTitle(String(localized: "moments.title", bundle: LanguageManager.shared.bundle))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.body)
                            .foregroundStyle(BrandColors.accent)
                    }
                }
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
                                .foregroundStyle(BrandColors.accent)
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .accessibilityLabel(vm.viewMode == .timeline
                            ? String(localized: "view.mode.grid", bundle: LanguageManager.shared.bundle)
                            : String(localized: "view.mode.timeline", bundle: LanguageManager.shared.bundle))
                    }
                }
            }
            .confirmationDialog(
                String(localized: "delete.confirm.title", bundle: LanguageManager.shared.bundle),
                isPresented: Binding(
                    get: { momentToDelete != nil },
                    set: { if !$0 { momentToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button(String(localized: "delete", bundle: LanguageManager.shared.bundle), role: .destructive) {
                    if let id = momentToDelete {
                        HapticManager.deleteWarning()
                        Task {
                            await timelineViewModel?.deleteMoment(id: id)
                        }
                    }
                    momentToDelete = nil
                }
                Button(String(localized: "cancel", bundle: LanguageManager.shared.bundle), role: .cancel) {
                    momentToDelete = nil
                }
            } message: {
                Text(String(localized: "delete.confirm.message", bundle: LanguageManager.shared.bundle))
            }
        }
        .tint(BrandColors.accent)
        .sheet(isPresented: $showCaptureMenu) {
            captureMenuSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $createMomentViewModel) { vm in
            CreateMomentView(
                viewModel: vm,
                onDismiss: {
                    createMomentViewModel = nil
                },
                onSaved: {
                    createMomentViewModel = nil
                    Task {
                        await timelineViewModel?.loadMoments()
                    }
                }
            )
        }
        .sheet(item: $selectedMoment) { moment in
            MomentDetailView(
                viewModel: MomentDetailViewModel(moment: moment, weatherService: container.weatherService),
                onDismiss: { selectedMoment = nil }
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
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
                fabScale = 0.85
                fabRotation = 90
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    fabScale = 1.0
                    fabRotation = 0
                }
                showCaptureMenu = true
            }
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(
                    Circle()
                        .fill(BrandColors.fabGradient)
                        .shadow(color: BrandColors.accent.opacity(0.35), radius: 12, y: 5)
                )
                .scaleEffect(fabScale)
                .rotationEffect(.degrees(fabRotation))
        }
        .accessibilityLabel(String(localized: "fab.accessibility", bundle: LanguageManager.shared.bundle))
    }

    // MARK: - Capture Menu Sheet

    private var captureMenuSheet: some View {
        VStack(spacing: 12) {
            if let denied = permissionDeniedType {
                permissionDeniedBanner(for: denied)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            CaptureMenuView(
                isCameraAvailable: true,
                isVoiceAvailable: true,
                isGalleryAvailable: true,
                onCameraTap: {
                    Task {
                        let status = await container.permissionService.request(.camera)
                        if status == .authorized {
                            startCapture(step: .camera)
                        } else if status == .denied {
                            withAnimation { permissionDeniedType = "Camera" }
                        }
                    }
                },
                onVoiceTap: {
                    Task {
                        let status = await container.permissionService.request(.microphone)
                        if status == .authorized {
                            _ = await container.permissionService.request(.speechRecognition)
                            startCapture(step: .voice)
                        } else if status == .denied {
                            withAnimation { permissionDeniedType = "Microphone" }
                        }
                    }
                },
                onGalleryTap: {
                    Task {
                        let status = await container.permissionService.request(.photoLibrary)
                        if status == .authorized {
                            startCapture(step: .gallery)
                        } else if status == .denied {
                            withAnimation { permissionDeniedType = "Photo Library" }
                        }
                    }
                }
            )
        }
        .padding(.top, 8)
    }

    private func startCapture(step: CreateMomentStep) {
        showCaptureMenu = false
        permissionDeniedType = nil
        createMomentViewModel = container.makeCreateMomentViewModel(initialStep: step)
    }

    private func permissionDeniedBanner(for type: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "permission.denied \(type)", bundle: LanguageManager.shared.bundle))
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                Text(String(localized: "permission.enable.settings", bundle: LanguageManager.shared.bundle))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(String(localized: "settings", bundle: LanguageManager.shared.bundle)) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(.blue))
            .foregroundStyle(.white)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
        .padding(.horizontal, 20)
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
                    isLoadingMore: vm.isLoadingMore,
                    hasMoreOlderMoments: vm.hasMoreOlderMoments,
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
                    },
                    onLoadMore: {
                        await vm.loadMoreMoments()
                    }
                )
                .transition(.move(edge: .leading).combined(with: .opacity))
            case .grid:
                GridView(
                    moments: vm.moments,
                    isLoadingMore: vm.isLoadingMore,
                    hasMoreOlderMoments: vm.hasMoreOlderMoments,
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
                    },
                    onLoadMore: {
                        await vm.loadMoreMoments()
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }

    // MARK: - Error State

    private func errorState(message: String, vm: TimelineViewModel) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(.orange)
            }

            Text(String(localized: "error.title", bundle: LanguageManager.shared.bundle))
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
            Text(message)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(BrandColors.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await vm.loadMoments() }
            } label: {
                Text(String(localized: "try.again", bundle: LanguageManager.shared.bundle))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(BrandColors.accent))
                    .foregroundStyle(.white)
            }
            .padding(.top, 4)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
