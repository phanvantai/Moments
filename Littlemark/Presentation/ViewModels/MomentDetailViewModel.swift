import Foundation

@Observable
@MainActor
final class MomentDetailViewModel {
    let moment: Moment

    init(moment: Moment) {
        self.moment = moment
    }

    var title: String? {
        guard let title = moment.title, !title.isEmpty else { return nil }
        return title
    }

    var text: String? {
        guard let text = moment.text, !text.isEmpty else { return nil }
        return text
    }

    var mediaItems: [MediaItem] {
        moment.mediaItems
    }

    var voiceNote: VoiceNote? {
        moment.voiceNote
    }

    var categories: [MomentCategory] {
        moment.categories
    }

    var tags: [String] {
        moment.tags
    }

    var weather: Weather? {
        moment.weather
    }

    var location: Location? {
        moment.location
    }

    var createdAt: Date {
        moment.createdAt
    }

    var showMap: Bool {
        moment.location != nil
    }

    var showWeather: Bool {
        moment.weather != nil
    }

    var showVoicePlayer: Bool {
        moment.voiceNote != nil
    }

    var showPagerDots: Bool {
        moment.mediaItems.count > 1
    }

    var hasMedia: Bool {
        !moment.mediaItems.isEmpty
    }

    var hasCategories: Bool {
        !moment.categories.isEmpty
    }

    var hasTags: Bool {
        !moment.tags.isEmpty
    }
}
