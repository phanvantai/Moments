import SwiftUI

struct ReviewMomentView: View {
    @Bindable var viewModel: CreateMomentViewModel
    var onDismiss: () -> Void

    @State private var newTag: String = ""
    @State private var isShowingLocationPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Media Preview
                    mediaPreviewSection

                    // Voice Note
                    if let voiceNote = viewModel.voiceNote {
                        voiceNoteSection(voiceNote)
                    }

                    // Text Field
                    textSection

                    // Date & Time
                    dateTimeSection

                    // Smart Features
                    smartFeaturesSection

                    // Tags
                    tagsSection
                }
                .padding()
            }
            .task {
                await viewModel.loadSmartFeatures()
            }
            .navigationTitle(String(localized: "review.title", bundle: LanguageManager.shared.bundle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel", bundle: LanguageManager.shared.bundle)) { onDismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "save", bundle: LanguageManager.shared.bundle)) {
                        Task { await viewModel.save() }
                    }
                    .disabled(!viewModel.canSave)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(viewModel.canSave ? BrandColors.accent : .gray)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    ZStack {
                        Color.black.opacity(0.1)
                            .ignoresSafeArea()
                        VStack(spacing: 12) {
                            ProgressView()
                                .controlSize(.regular)
                            Text(String(localized: "saving", bundle: LanguageManager.shared.bundle))
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .transition(.opacity)
                }
            }
            .alert(String(localized: "save.failed", bundle: LanguageManager.shared.bundle), isPresented: showSaveError) {
                Button(String(localized: "retry", bundle: LanguageManager.shared.bundle)) {
                    Task { await viewModel.save() }
                }
                Button(String(localized: "cancel", bundle: LanguageManager.shared.bundle), role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? String(localized: "save.error.message", bundle: LanguageManager.shared.bundle))
            }
            .fullScreenCover(isPresented: $isShowingLocationPicker) {
                LocationPickerView(
                    initialLocation: viewModel.currentLocation,
                    onLocationSelected: { location in
                        Task { await viewModel.updateLocation(location) }
                        isShowingLocationPicker = false
                    },
                    onDismiss: {
                        isShowingLocationPicker = false
                    }
                )
            }
        }
    }

    private var showSaveError: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil && !viewModel.isSaving },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    // MARK: - Media Preview

    @ViewBuilder
    private var mediaPreviewSection: some View {
        if !viewModel.capturedMediaItems.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.capturedMediaItems) { item in
                        MediaThumbnailView(item: item) {
                            viewModel.removeMedia(item.id)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Voice Note Section

    private func voiceNoteSection(_ voiceNote: VoiceNote) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform")
                .font(.title3)
                .foregroundStyle(BrandColors.categoryRed)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "voice.note", bundle: LanguageManager.shared.bundle))
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                Text(DurationFormatter.shortFormat(voiceNote.duration))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(BrandColors.textSecondary)
                if let transcript = voiceNote.transcript, !transcript.isEmpty {
                    Text(transcript)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(BrandColors.textSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Button {
                viewModel.removeVoiceNote()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(BrandColors.categoryRed.opacity(0.08))
        )
    }

    // MARK: - Text Section

    private var textSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "description", bundle: LanguageManager.shared.bundle))
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(BrandColors.sectionHeader)

            TextField(String(localized: "description.placeholder", bundle: LanguageManager.shared.bundle), text: $viewModel.text, axis: .vertical)
                .lineLimit(3...6)
                .font(.system(.body, design: .rounded))
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
        }
    }

    // MARK: - Tags Section

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "tags", bundle: LanguageManager.shared.bundle))
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(BrandColors.sectionHeader)

            // Existing tags
            if !viewModel.tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.tags, id: \.self) { tag in
                        TagChip(tag: tag) {
                            viewModel.removeTag(tag)
                        }
                    }
                }
            }

            // Add new tag
            HStack {
                TextField(String(localized: "tags.placeholder", bundle: LanguageManager.shared.bundle), text: $newTag)
                    .font(.system(.body, design: .rounded))
                    .onSubmit {
                        addCurrentTag()
                    }

                Button {
                    addCurrentTag()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(BrandColors.accent)
                }
                .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }

    // MARK: - Date & Time

    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "date.time", bundle: LanguageManager.shared.bundle))
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(BrandColors.sectionHeader)

            DatePicker(
                String(localized: "date.time", bundle: LanguageManager.shared.bundle),
                selection: $viewModel.selectedDate,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .font(.system(.body, design: .rounded))
            .tint(BrandColors.accent)
            .onChange(of: viewModel.selectedDate) { _, newDate in
                Task { await viewModel.updateDate(newDate) }
            }
        }
    }

    // MARK: - Smart Features

    private var smartFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Location
            if let location = viewModel.currentLocation, viewModel.isLocationEnabled {
                HStack {
                    LocationBadgeView(location: location) {
                        viewModel.disableLocation()
                    }

                    Spacer()

                    Button {
                        isShowingLocationPicker = true
                    } label: {
                        Label(String(localized: "edit.location", bundle: LanguageManager.shared.bundle),
                              systemImage: "pencil")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(BrandColors.accent)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Button {
                    isShowingLocationPicker = true
                } label: {
                    Label(String(localized: "add.location", bundle: LanguageManager.shared.bundle),
                          systemImage: "mappin.circle")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .stroke(BrandColors.categoryRed.opacity(0.3), lineWidth: 1)
                        )
                        .foregroundStyle(BrandColors.categoryRed)
                }
                .buttonStyle(.plain)
            }

            // Weather
            if let weather = viewModel.currentWeather {
                WeatherBadgeView(weather: weather)
            }

            // Suggested Categories
            if !viewModel.suggestedCategoryKeys.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "categories", bundle: LanguageManager.shared.bundle))
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(BrandColors.sectionHeader)

                    FlowLayout(spacing: 8) {
                        ForEach(viewModel.suggestedCategoryKeys, id: \.self) { key in
                            if let category = MomentCategory.find(byKey: key) {
                                CategoryBadgeView(
                                    category: category,
                                    isSelected: viewModel.selectedCategoryKeys.contains(key)
                                ) {
                                    viewModel.toggleCategory(key)
                                }
                            }
                        }
                    }
                }
            }

            if viewModel.isLoadingSmartFeatures {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text(String(localized: "analyzing", bundle: LanguageManager.shared.bundle))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(BrandColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Helpers

    private func addCurrentTag() {
        let tag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty else { return }
        viewModel.addTag(tag)
        newTag = ""
    }


}

// MARK: - Media Thumbnail View

private struct MediaThumbnailView: View {
    let item: MediaItem
    let onRemove: () -> Void

    @State private var thumbnailImage: UIImage?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .frame(width: 120, height: 120)
                .overlay {
                    if let image = thumbnailImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .transition(.opacity.animation(.easeOut(duration: 0.2)))
                    } else {
                        Image(systemName: item.type == .video ? "video.fill" : "photo.fill")
                            .font(.title2)
                            .foregroundStyle(.tertiary)
                    }
                }

            // Media type badge
            if thumbnailImage != nil {
                Image(systemName: item.type == .video ? "video.fill" : "photo.fill")
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(Circle().fill(.black.opacity(0.45)))
                    .offset(x: -8, y: 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.55))
            }
            .offset(x: 6, y: -6)
        }
        .task {
            let path = item.thumbnailPath ?? item.filePath
            thumbnailImage = await ThumbnailCache.shared.loadThumbnail(for: path)
        }
    }
}

// MARK: - Tag Chip

private struct TagChip: View {
    let tag: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.system(.caption, design: .rounded, weight: .medium))
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(BrandColors.categoryBlue.opacity(0.10)))
        .foregroundStyle(BrandColors.categoryBlue)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                                  proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return LayoutResult(
            positions: positions,
            size: CGSize(width: maxWidth, height: y + rowHeight)
        )
    }

    private struct LayoutResult {
        var positions: [CGPoint]
        var size: CGSize
    }
}
