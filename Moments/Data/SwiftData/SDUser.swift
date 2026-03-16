import Foundation
import SwiftData

@Model
final class SDUser {
    var id: UUID = UUID()
    var displayName: String = ""
    var avatarPath: String?
    var createdAt: Date = Date()
    var homeLocationLatitude: Double?
    var homeLocationLongitude: Double?
    var homeLocationName: String?
    var homeLocationAddress: String?
    var homeLocationPlaceType: String?

    init(
        id: UUID = UUID(),
        displayName: String,
        avatarPath: String? = nil,
        createdAt: Date = Date(),
        homeLocationLatitude: Double? = nil,
        homeLocationLongitude: Double? = nil,
        homeLocationName: String? = nil,
        homeLocationAddress: String? = nil,
        homeLocationPlaceType: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.avatarPath = avatarPath
        self.createdAt = createdAt
        self.homeLocationLatitude = homeLocationLatitude
        self.homeLocationLongitude = homeLocationLongitude
        self.homeLocationName = homeLocationName
        self.homeLocationAddress = homeLocationAddress
        self.homeLocationPlaceType = homeLocationPlaceType
    }
}
