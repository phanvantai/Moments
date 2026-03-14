import SwiftUI

struct TimelineNodeViewModel {
    let moment: Moment
    let index: Int

    var isTopAligned: Bool {
        index % 2 == 0
    }

    var displayTitle: String {
        MomentDisplayHelper.displayTitle(for: moment)
    }

    var categoryColor: Color {
        MomentDisplayHelper.categoryColor(for: moment)
    }

    var categoryEmoji: String? {
        moment.categories.first?.emoji
    }

    var createdAt: Date {
        moment.createdAt
    }

    var hasPhotoBadge: Bool {
        MomentDisplayHelper.hasPhotoBadge(moment)
    }

    var hasVideoBadge: Bool {
        MomentDisplayHelper.hasVideoBadge(moment)
    }

    var hasVoiceBadge: Bool {
        MomentDisplayHelper.hasVoiceBadge(moment)
    }

    var momentId: UUID {
        moment.id
    }

    var thumbnailPath: String? {
        guard let firstMedia = moment.mediaItems.first else { return nil }
        return firstMedia.thumbnailPath ?? firstMedia.filePath
    }
}
