import SwiftUI
import MapKit

struct MomentDetailView: View {
    let viewModel: MomentDetailViewModel
    let onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.hasMedia {
                        GeometryReader { geometry in
                            MediaViewer(viewModel: MediaViewerViewModel(mediaItems: viewModel.mediaItems))
                                .frame(width: geometry.size.width)
                        }
                        .frame(height: min(400, UIScreen.main.bounds.height * 0.45))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        if let title = viewModel.title {
                            Text(title)
                                .font(.system(.title2, design: .rounded, weight: .bold))
                        }

                        if let text = viewModel.text {
                            Text(text)
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(.primary)
                        }

                        if let voiceNote = viewModel.voiceNote {
                            VoicePlayerView(viewModel: VoicePlayerViewModel(voiceNote: voiceNote))
                        }

                        if viewModel.hasCategories {
                            categorySection
                        }

                        if viewModel.hasTags {
                            tagsSection
                        }

                        if let weather = viewModel.weather {
                            weatherBadge(weather)
                        }

                        if let location = viewModel.location {
                            miniMap(location)
                        }

                        timestampSection
                    }
                    .padding(.horizontal, 16)
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
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Sections

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Categories")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
            FlowLayout(spacing: 6) {
                ForEach(viewModel.categories) { category in
                    HStack(spacing: 4) {
                        Text(category.emoji)
                            .font(.system(size: 14))
                        Text(category.label)
                            .font(.system(.caption, design: .rounded))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.primary.opacity(0.05))
                    )
                }
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tags")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
            FlowLayout(spacing: 6) {
                ForEach(viewModel.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.system(.caption, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
        }
    }

    private func weatherBadge(_ weather: Weather) -> some View {
        HStack(spacing: 8) {
            Image(systemName: weather.icon)
                .font(.title3)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(weather.condition)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                Text("\(Int(weather.temperature))°C")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }

    private func miniMap(_ location: Location) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let name = location.name, !name.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                    Text(name)
                        .font(.system(.subheadline, design: .rounded))
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
                    location.name ?? "Location",
                    coordinate: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                )
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .allowsHitTesting(false)
            .overlay(alignment: .bottomTrailing) {
                Label("Open in Maps", systemImage: "arrow.up.right.square")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
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
                mapItem.name = location.name ?? "Location"
                mapItem.openInMaps()
            }
        }
    }

    private var timestampSection: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(viewModel.createdAt, format: .dateTime.day().month().year().hour().minute())
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}


