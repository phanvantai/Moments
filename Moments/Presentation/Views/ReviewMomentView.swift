import SwiftUI

struct ReviewMomentView: View {
    @Bindable var viewModel: CreateMomentViewModel
    var onAddMoreMedia: () -> Void
    var onDismiss: () -> Void

    @State private var newTag: String = ""

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

                    // Smart Features
                    smartFeaturesSection

                    // Tags
                    tagsSection

                    // Add More Media
                    addMoreMediaButton
                }
                .padding()
            }
            .task {
                await viewModel.loadSmartFeatures()
            }
            .navigationTitle("Review Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await viewModel.save() }
                    }
                    .disabled(!viewModel.canSave)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
            .overlay {
                if viewModel.isSaving {
                    ProgressView("Saving...")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Media Preview

    @ViewBuilder
    private var mediaPreviewSection: some View {
        if !viewModel.capturedMediaItems.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
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
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 4) {
                Text("Voice Note")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                Text(DurationFormatter.shortFormat(voiceNote.duration))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                if let transcript = voiceNote.transcript, !transcript.isEmpty {
                    Text(transcript)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Button {
                viewModel.removeVoiceNote()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(.red.opacity(0.1)))
    }

    // MARK: - Text Section

    private var textSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)

            TextField("What happened in this moment?", text: $viewModel.text, axis: .vertical)
                .lineLimit(3...6)
                .font(.system(.body, design: .rounded))
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(.gray.opacity(0.1)))
        }
    }

    // MARK: - Tags Section

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)

            // Existing tags
            FlowLayout(spacing: 8) {
                ForEach(viewModel.tags, id: \.self) { tag in
                    TagChip(tag: tag) {
                        viewModel.removeTag(tag)
                    }
                }
            }

            // Add new tag
            HStack {
                TextField("Add tag...", text: $newTag)
                    .font(.system(.body, design: .rounded))
                    .onSubmit {
                        addCurrentTag()
                    }

                Button {
                    addCurrentTag()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
                .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(.gray.opacity(0.1)))
        }
    }

    // MARK: - Smart Features

    private var smartFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Location
            if let location = viewModel.currentLocation, viewModel.isLocationEnabled {
                LocationBadgeView(location: location) {
                    viewModel.disableLocation()
                }
            }

            // Weather
            if let weather = viewModel.currentWeather {
                WeatherBadgeView(weather: weather)
            }

            // Suggested Categories
            if !viewModel.suggestedCategoryKeys.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Categories")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)

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
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text("Analyzing...")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Add More Media

    private var addMoreMediaButton: some View {
        Button(action: onAddMoreMedia) {
            HStack {
                Image(systemName: "plus.circle")
                Text("Add more media")
            }
            .font(.system(.body, design: .rounded))
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).stroke(.blue.opacity(0.3), lineWidth: 1))
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

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.2))
                .frame(width: 120, height: 120)
                .overlay {
                    Image(systemName: item.type == .video ? "video.fill" : "photo.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .background(Circle().fill(.black.opacity(0.5)))
            }
            .offset(x: 6, y: -6)
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
                .font(.system(.caption, design: .rounded))
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(.blue.opacity(0.1)))
        .foregroundStyle(.blue)
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
