import SwiftUI
import MapKit

struct MomentDetailView: View {
    let viewModel: MomentDetailViewModel
    let onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if viewModel.hasMedia {
                        GeometryReader { geometry in
                            MediaViewer(viewModel: MediaViewerViewModel(mediaItems: viewModel.mediaItems))
                                .frame(width: geometry.size.width)
                        }
                        .frame(height: min(400, UIScreen.main.bounds.height * 0.45))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        // Title & Text
                        if viewModel.title != nil || viewModel.text != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                if let title = viewModel.title {
                                    Text(title)
                                        .font(.system(.title2, design: .rounded, weight: .bold))
                                }

                                if let text = viewModel.text {
                                    Text(text)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .lineSpacing(2)
                                }
                            }
                        }

                        // Voice Player
                        if let voiceNote = viewModel.voiceNote {
                            VoicePlayerView(viewModel: VoicePlayerViewModel(voiceNote: voiceNote))
                        }

                        // Metadata section
                        if viewModel.hasCategories || viewModel.hasTags || viewModel.weather != nil {
                            VStack(alignment: .leading, spacing: 14) {
                                if viewModel.hasCategories {
                                    categorySection
                                }

                                if viewModel.hasTags {
                                    tagsSection
                                }

                                if let weather = viewModel.weather {
                                    weatherBadge(weather)
                                    if let attribution = viewModel.weatherAttribution {
                                        WeatherAttributionView(attribution: attribution)
                                    }
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
                        }

                        // Location
                        if let location = viewModel.location {
                            miniMap(location)
                        }

                        timestampSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
            .task {
                await viewModel.loadWeatherAttribution()
            }
        }
    }

    // MARK: - Sections

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(String(localized: "categories", bundle: LanguageManager.shared.bundle), systemImage: "tag")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(BrandColors.sectionHeader)
            FlowLayout(spacing: 6) {
                ForEach(viewModel.categories) { category in
                    HStack(spacing: 4) {
                        Text(category.emoji)
                            .font(.system(size: 14))
                        Text(category.label)
                            .font(.system(.caption, design: .rounded, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(MomentDisplayHelper.color(forCategoryKey: category.key).opacity(0.12))
                    )
                    .foregroundStyle(MomentDisplayHelper.color(forCategoryKey: category.key))
                }
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(String(localized: "tags", bundle: LanguageManager.shared.bundle), systemImage: "number")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(BrandColors.sectionHeader)
            FlowLayout(spacing: 6) {
                ForEach(viewModel.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(BrandColors.categoryBlue.opacity(0.10))
                        )
                        .foregroundStyle(BrandColors.categoryBlue)
                }
            }
        }
    }

    private func weatherBadge(_ weather: Weather) -> some View {
        HStack(spacing: 10) {
            Image(systemName: weather.icon)
                .font(.title3)
                .foregroundStyle(BrandColors.categoryOrange)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(weather.condition)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                Text("\(Int(weather.temperature))°C")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(BrandColors.textSecondary)
            }
        }
    }

    private func miniMap(_ location: Location) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let name = location.name, !name.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(BrandColors.categoryRed)
                    Text(name)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                }
            }

            Map(initialPosition: .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )) {
                Marker(
                    location.name ?? String(localized: "location.fallback", bundle: LanguageManager.shared.bundle),
                    coordinate: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                )
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .allowsHitTesting(false)
            .overlay(alignment: .bottomTrailing) {
                Label(String(localized: "open.in.maps", bundle: LanguageManager.shared.bundle), systemImage: "arrow.up.right.square")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(.black.opacity(0.5)))
                    .padding(8)
            }
            .onTapGesture {
                let coordinate = CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                let placemark = MKPlacemark(coordinate: coordinate)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = location.name ?? String(localized: "location.fallback", bundle: LanguageManager.shared.bundle)
                mapItem.openInMaps()
            }
        }
    }

    private var timestampSection: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock")
                .font(.caption)
                .foregroundStyle(BrandColors.textSecondary)
            Text(viewModel.createdAt, format: .dateTime.day().month().year().hour().minute())
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(BrandColors.textSecondary)
        }
        .padding(.top, 4)
    }
}
