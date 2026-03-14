import SwiftUI

struct GridCardViewModel {
    let moment: Moment

    var displayTitle: String {
        MomentDisplayHelper.displayTitle(for: moment)
    }

    var categoryColor: Color {
        MomentDisplayHelper.categoryColor(for: moment)
    }

    var createdAt: Date {
        moment.createdAt
    }

    var categoryBadges: [MomentCategory] {
        Array(moment.categories.prefix(3))
    }

    var hasThumbnail: Bool {
        !moment.mediaItems.isEmpty
    }

    var thumbnailURL: URL? {
        MomentDisplayHelper.thumbnailURL(for: moment)
    }

    var placeholderEmoji: String? {
        moment.categories.first?.emoji
    }

    var isVoiceOnly: Bool {
        moment.mediaItems.isEmpty && moment.voiceNote != nil
    }
}
