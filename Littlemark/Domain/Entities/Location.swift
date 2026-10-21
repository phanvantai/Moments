import Foundation

struct Location: Equatable, Hashable, Sendable {
    let latitude: Double
    let longitude: Double
    let name: String?
    let address: String?
    let placeType: String?

    init(
        latitude: Double,
        longitude: Double,
        name: String? = nil,
        address: String? = nil,
        placeType: String? = nil
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.address = address
        self.placeType = placeType
    }

    func distance(to other: Location) -> Double {
        let earthRadius = 6_371_000.0 // meters
        let lat1 = latitude * .pi / 180
        let lat2 = other.latitude * .pi / 180
        let dLat = (other.latitude - latitude) * .pi / 180
        let dLon = (other.longitude - longitude) * .pi / 180

        let a = sin(dLat / 2) * sin(dLat / 2) +
                 cos(lat1) * cos(lat2) *
                 sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }
}
