import Foundation

enum MomentMapper {

    // MARK: - Domain → SwiftData

    static func toSDModel(_ moment: Moment) -> SDMoment {
        let sdMoment = SDMoment(
            id: moment.id,
            userId: moment.userId,
            createdAt: moment.createdAt,
            updatedAt: moment.updatedAt,
            title: moment.title,
            text: moment.text,
            mediaItems: moment.mediaItems.map { toSDModel($0) },
            voiceNoteFilePath: moment.voiceNote?.filePath,
            voiceNoteDuration: moment.voiceNote?.duration,
            voiceNoteTranscript: moment.voiceNote?.transcript,
            locationLatitude: moment.location?.latitude,
            locationLongitude: moment.location?.longitude,
            locationName: moment.location?.name,
            locationAddress: moment.location?.address,
            locationPlaceType: moment.location?.placeType,
            categoryKeys: moment.categories.map(\.key),
            tags: moment.tags,
            isFavorite: moment.isFavorite,
            weatherCondition: moment.weather?.condition,
            weatherTemperature: moment.weather?.temperature,
            weatherIcon: moment.weather?.icon,
            visibility: moment.visibility.rawValue
        )
        return sdMoment
    }

    static func toSDModel(_ mediaItem: MediaItem) -> SDMediaItem {
        SDMediaItem(
            id: mediaItem.id,
            momentId: mediaItem.momentId,
            type: mediaItem.type.rawValue,
            filePath: mediaItem.filePath,
            thumbnailPath: mediaItem.thumbnailPath,
            duration: mediaItem.duration,
            width: mediaItem.width,
            height: mediaItem.height,
            sortOrder: mediaItem.sortOrder
        )
    }

    // MARK: - SwiftData → Domain

    static func toDomain(_ sdMoment: SDMoment) -> Moment {
        let voiceNote: VoiceNote?
        if let filePath = sdMoment.voiceNoteFilePath,
           let duration = sdMoment.voiceNoteDuration {
            voiceNote = VoiceNote(
                filePath: filePath,
                duration: duration,
                transcript: sdMoment.voiceNoteTranscript
            )
        } else {
            voiceNote = nil
        }

        let location: Location?
        if let lat = sdMoment.locationLatitude,
           let lon = sdMoment.locationLongitude {
            location = Location(
                latitude: lat,
                longitude: lon,
                name: sdMoment.locationName,
                address: sdMoment.locationAddress,
                placeType: sdMoment.locationPlaceType
            )
        } else {
            location = nil
        }

        let weather: Weather?
        if let condition = sdMoment.weatherCondition,
           let temperature = sdMoment.weatherTemperature,
           let icon = sdMoment.weatherIcon {
            weather = Weather(
                condition: condition,
                temperature: temperature,
                icon: icon
            )
        } else {
            weather = nil
        }

        let categories = sdMoment.categoryKeys.compactMap { MomentCategory.find(byKey: $0) }
        let visibility = MomentVisibility(rawValue: sdMoment.visibility) ?? .private

        return Moment(
            id: sdMoment.id,
            userId: sdMoment.userId,
            createdAt: sdMoment.createdAt,
            updatedAt: sdMoment.updatedAt,
            title: sdMoment.title,
            text: sdMoment.text,
            mediaItems: (sdMoment.mediaItems ?? []).map { toDomain($0) },
            voiceNote: voiceNote,
            location: location,
            categories: categories,
            tags: sdMoment.tags,
            isFavorite: sdMoment.isFavorite,
            weather: weather,
            visibility: visibility
        )
    }

    static func toDomain(_ sdMediaItem: SDMediaItem) -> MediaItem {
        MediaItem(
            id: sdMediaItem.id,
            momentId: sdMediaItem.momentId,
            type: MediaType(rawValue: sdMediaItem.type) ?? .photo,
            filePath: sdMediaItem.filePath,
            thumbnailPath: sdMediaItem.thumbnailPath,
            duration: sdMediaItem.duration,
            width: sdMediaItem.width,
            height: sdMediaItem.height,
            sortOrder: sdMediaItem.sortOrder
        )
    }

    // MARK: - Update existing SDMoment from Domain

    static func update(_ sdMoment: SDMoment, from moment: Moment) {
        sdMoment.updatedAt = moment.updatedAt
        sdMoment.title = moment.title
        sdMoment.text = moment.text
        sdMoment.voiceNoteFilePath = moment.voiceNote?.filePath
        sdMoment.voiceNoteDuration = moment.voiceNote?.duration
        sdMoment.voiceNoteTranscript = moment.voiceNote?.transcript
        sdMoment.locationLatitude = moment.location?.latitude
        sdMoment.locationLongitude = moment.location?.longitude
        sdMoment.locationName = moment.location?.name
        sdMoment.locationAddress = moment.location?.address
        sdMoment.locationPlaceType = moment.location?.placeType
        sdMoment.categoryKeys = moment.categories.map(\.key)
        sdMoment.tags = moment.tags
        sdMoment.isFavorite = moment.isFavorite
        sdMoment.weatherCondition = moment.weather?.condition
        sdMoment.weatherTemperature = moment.weather?.temperature
        sdMoment.weatherIcon = moment.weather?.icon
        sdMoment.visibility = moment.visibility.rawValue
    }
}

enum UserMapper {

    static func toSDModel(_ user: User) -> SDUser {
        SDUser(
            id: user.id,
            displayName: user.displayName,
            avatarPath: user.avatarPath,
            createdAt: user.createdAt,
            homeLocationLatitude: user.homeLocation?.latitude,
            homeLocationLongitude: user.homeLocation?.longitude,
            homeLocationName: user.homeLocation?.name,
            homeLocationAddress: user.homeLocation?.address,
            homeLocationPlaceType: user.homeLocation?.placeType
        )
    }

    static func toDomain(_ sdUser: SDUser) -> User {
        let homeLocation: Location?
        if let lat = sdUser.homeLocationLatitude,
           let lon = sdUser.homeLocationLongitude {
            homeLocation = Location(
                latitude: lat,
                longitude: lon,
                name: sdUser.homeLocationName,
                address: sdUser.homeLocationAddress,
                placeType: sdUser.homeLocationPlaceType
            )
        } else {
            homeLocation = nil
        }

        return User(
            id: sdUser.id,
            displayName: sdUser.displayName,
            avatarPath: sdUser.avatarPath,
            createdAt: sdUser.createdAt,
            homeLocation: homeLocation
        )
    }
}
