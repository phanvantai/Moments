import SwiftUI

enum MomentDisplayHelper {
    static func displayTitle(for moment: Moment) -> String {
        if let title = moment.title, !title.isEmpty {
            return title
        }
        if let text = moment.text, !text.isEmpty {
            // Views limit the lines and add the ellipsis
            return text
        }
        if let category = moment.categories.first {
            return label(for: category)
        }
        return "Moment"
    }

    /// Category name in the app language (the domain `label` is the Vietnamese default).
    static func label(for category: MomentCategory, bundle: Bundle? = nil) -> String {
        (bundle ?? LanguageManager.shared.bundle)
            .localizedString(forKey: "category.\(category.key)", value: category.label, table: nil)
    }

    static func categoryColor(for moment: Moment) -> Color {
        guard let category = moment.categories.first else {
            return BrandColors.categoryBlue
        }
        return color(forCategoryKey: category.key)
    }

    static func color(forCategoryKey key: String) -> Color {
        switch key {
        case "first-time": return BrandColors.categoryYellow
        case "milestone": return BrandColors.categoryOrange
        case "daily": return BrandColors.categoryBlue
        case "outdoor": return BrandColors.categoryGreen
        case "family": return BrandColors.categoryPurple
        case "health": return BrandColors.categoryRed
        case "travel": return BrandColors.categoryCyan
        case "food": return BrandColors.categoryPink
        case "play": return BrandColors.categoryIndigo
        case "learn": return BrandColors.categoryTeal
        default: return BrandColors.categoryBlue
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
