import CoreLocation

final class LocationService: NSObject, LocationServiceProtocol, @unchecked Sendable {

    func getCurrentLocation() async -> Location? {
        let manager = CLLocationManager()

        guard manager.authorizationStatus == .authorizedWhenInUse
                || manager.authorizationStatus == .authorizedAlways else {
            return nil
        }

        guard let clLocation = await requestLocation(manager: manager) else {
            return nil
        }

        let geocodeResult = await reverseGeocode(clLocation)
        return Location(
            latitude: clLocation.coordinate.latitude,
            longitude: clLocation.coordinate.longitude,
            name: geocodeResult?.name,
            address: geocodeResult?.address,
            placeType: geocodeResult?.placeType
        )
    }

    // MARK: - Private

    private func requestLocation(manager: CLLocationManager) async -> CLLocation? {
        let delegate = LocationDelegate()
        manager.delegate = delegate
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestLocation()
        return await delegate.waitForLocation()
    }

    private func reverseGeocode(_ location: CLLocation) async -> GeocodeResult? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else { return nil }
            return GeocodeResult(
                name: placemark.name ?? placemark.locality,
                address: formatAddress(placemark),
                placeType: mapPlaceType(placemark)
            )
        } catch {
            return nil
        }
    }

    private func formatAddress(_ placemark: CLPlacemark) -> String? {
        let components = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.subLocality,
            placemark.locality
        ].compactMap { $0 }

        return components.isEmpty ? nil : components.joined(separator: ", ")
    }

    private func mapPlaceType(_ placemark: CLPlacemark) -> String? {
        if let areasOfInterest = placemark.areasOfInterest, !areasOfInterest.isEmpty {
            let name = areasOfInterest[0].lowercased()
            if name.contains("park") || name.contains("garden") { return "park" }
            if name.contains("hospital") || name.contains("clinic") { return "hospital" }
            if name.contains("restaurant") || name.contains("cafe") || name.contains("food") { return "restaurant" }
            if name.contains("school") || name.contains("university") { return "school" }
            if name.contains("museum") || name.contains("gallery") { return "museum" }
            if name.contains("airport") || name.contains("station") { return "transport" }
            if name.contains("hotel") || name.contains("resort") { return "hotel" }
            if name.contains("mall") || name.contains("shop") || name.contains("market") { return "shopping" }
            if name.contains("beach") { return "beach" }
            if name.contains("temple") || name.contains("church") || name.contains("mosque") { return "worship" }
        }

        // Fallback based on placemark properties
        if placemark.ocean != nil { return "ocean" }
        if placemark.inlandWater != nil { return "water" }

        return nil
    }
}

// MARK: - Geocode Result

private struct GeocodeResult {
    let name: String?
    let address: String?
    let placeType: String?
}

// MARK: - Location Delegate

private final class LocationDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    private var continuation: CheckedContinuation<CLLocation?, Never>?

    func waitForLocation() async -> CLLocation? {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(returning: locations.first)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(returning: nil)
    }
}
