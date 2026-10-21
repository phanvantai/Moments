import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerView: View {
    let initialLocation: Location?
    let onLocationSelected: (Location) -> Void
    let onDismiss: () -> Void

    @State private var searchText: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedLocation: Location?
    @State private var isSearching: Bool = false
    @State private var cameraPosition: MapCameraPosition
    @State private var searchTask: Task<Void, Never>?

    init(
        initialLocation: Location?,
        onLocationSelected: @escaping (Location) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.initialLocation = initialLocation
        self.onLocationSelected = onLocationSelected
        self.onDismiss = onDismiss

        if let loc = initialLocation {
            _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )))
            _selectedLocation = State(initialValue: loc)
        } else {
            _cameraPosition = State(initialValue: .automatic)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Map background
                mapLayer

                // Overlay UI
                VStack(spacing: 0) {
                    searchBar
                        .padding(.horizontal)
                        .padding(.top, 8)

                    if !searchResults.isEmpty {
                        searchResultsList
                    }

                    Spacer()

                    if let location = selectedLocation {
                        selectedLocationCard(location)
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        hintLabel
                            .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle(String(localized: "location.picker.title", bundle: LanguageManager.shared.bundle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel", bundle: LanguageManager.shared.bundle)) {
                        onDismiss()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.25), value: selectedLocation != nil)
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        MapReader { proxy in
            Map(position: $cameraPosition) {
                if let location = selectedLocation {
                    Marker(
                        location.name ?? String(
                            format: "%.4f, %.4f",
                            location.latitude,
                            location.longitude
                        ),
                        coordinate: CLLocationCoordinate2D(
                            latitude: location.latitude,
                            longitude: location.longitude
                        )
                    )
                    .tint(BrandColors.accent)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .including([
                .cafe, .restaurant, .park, .museum, .hospital,
                .school, .airport, .hotel, .store
            ])))
            .onTapGesture { screenPoint in
                if let coordinate = proxy.convert(screenPoint, from: .local) {
                    handleMapTap(coordinate)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)

            TextField(
                String(localized: "location.picker.search", bundle: LanguageManager.shared.bundle),
                text: $searchText
            )
            .font(.system(.body, design: .rounded))
            .autocorrectionDisabled()

            if isSearching {
                ProgressView()
                    .controlSize(.small)
            } else if !searchText.isEmpty {
                Button {
                    searchText = ""
                    searchResults = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThickMaterial)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .onChange(of: searchText) { _, newValue in
            debounceSearch(newValue)
        }
    }

    // MARK: - Search Results

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchResults, id: \.self) { item in
                    Button {
                        selectMapItem(item)
                    } label: {
                        searchResultRow(item)
                    }
                    .buttonStyle(.plain)

                    if item != searchResults.last {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .frame(maxHeight: 280)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThickMaterial)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private func searchResultRow(_ item: MKMapItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(BrandColors.categoryRed)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name ?? "")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if let address = formatPlacemarkAddress(item.placemark) {
                    Text(address)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    // MARK: - Selected Location Card

    private func selectedLocationCard(_ location: Location) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(BrandColors.categoryRed)

                VStack(alignment: .leading, spacing: 2) {
                    Text(location.name ?? String(
                        format: "%.4f, %.4f",
                        location.latitude,
                        location.longitude
                    ))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .lineLimit(1)

                    if let address = location.address {
                        Text(address)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()
            }

            Button {
                onLocationSelected(location)
            } label: {
                Text(String(localized: "location.picker.confirm", bundle: LanguageManager.shared.bundle))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(BrandColors.accent)
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThickMaterial)
        )
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }

    // MARK: - Hint Label

    private var hintLabel: some View {
        Text(String(localized: "location.picker.tap.hint", bundle: LanguageManager.shared.bundle))
            .font(.system(.caption, design: .rounded, weight: .medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThickMaterial)
            )
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    // MARK: - Search Logic

    private func debounceSearch(_ query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await performSearch(trimmed)
        }
    }

    private func performSearch(_ query: String) async {
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            if !Task.isCancelled {
                searchResults = response.mapItems
            }
        } catch {
            if !Task.isCancelled {
                searchResults = []
            }
        }
        isSearching = false
    }

    // MARK: - Selection

    private func selectMapItem(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        selectedLocation = Location(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            name: item.name,
            address: formatPlacemarkAddress(item.placemark),
            placeType: nil
        )
        cameraPosition = .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        searchResults = []
        searchText = ""
    }

    private func handleMapTap(_ coordinate: CLLocationCoordinate2D) {
        selectedLocation = Location(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            name: nil,
            address: nil,
            placeType: nil
        )
        searchResults = []

        // Reverse geocode in background
        Task {
            await reverseGeocode(coordinate)
        }
    }

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(clLocation)
            guard let placemark = placemarks.first else { return }
            selectedLocation = Location(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                name: placemark.name ?? placemark.locality,
                address: formatPlacemarkAddress(placemark),
                placeType: nil
            )
        } catch {
            // Keep the coordinate-only location
        }
    }

    // MARK: - Helpers

    private func formatPlacemarkAddress(_ placemark: CLPlacemark) -> String? {
        let components = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.subLocality,
            placemark.locality
        ].compactMap { $0 }
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }

    private func formatPlacemarkAddress(_ placemark: MKPlacemark) -> String? {
        let components = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.subLocality,
            placemark.locality
        ].compactMap { $0 }
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}
