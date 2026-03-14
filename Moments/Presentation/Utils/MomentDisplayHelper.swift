import SwiftUI

enum MomentDisplayHelper {
    static func displayTitle(for moment: Moment) -> String {
        if let title = moment.title, !title.isEmpty {
            return title
        }
        if let text = moment.text, !text.isEmpty {
            return String(text.prefix(30))
        }
        if let category = moment.categories.first {
            return category.label
        }
        return "Moment"
    }

    static func categoryColor(for moment: Moment) -> Color {
        guard let category = moment.categories.first else {
            return .blue
        }
        return color(forCategoryKey: category.key)
    }

    static func color(forCategoryKey key: String) -> Color {
        switch key {
        case "first-time": return .yellow
        case "milestone": return .orange
        case "daily": return .blue
        case "outdoor": return .green
        case "family": return .purple
        case "health": return .red
        case "travel": return .cyan
        case "food": return .pink
        case "play": return .indigo
        case "learn": return .teal
        default: return .blue
        }
    }

    static func hasPhotoBadge(_ moment: Moment) -> Bool {
        moment.mediaItems.contains(where: { $0.type == .photo })
    }

    static func hasVideoBadge(_ moment: Moment) -> Bool {
        moment.mediaItems.contains(where: { $0.type == .video })
    }

    static func hasVoiceBadge(_ moment: Moment) -> Bool {
        moment.voiceNote != nil
    }

    static func thumbnailURL(for moment: Moment) -> URL? {
        guard let firstMedia = moment.mediaItems.first else { return nil }
        let path = firstMedia.thumbnailPath ?? firstMedia.filePath
        return mediaFileURL(path)
    }

    static func mediaFileURL(_ path: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent(path)
    }
}
