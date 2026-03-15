import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case japanese = "ja"
    case vietnamese = "vi"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: "English"
        case .japanese: "日本語"
        case .vietnamese: "Tiếng Việt"
        }
    }

    var flag: String {
        switch self {
        case .english: "🇺🇸"
        case .japanese: "🇯🇵"
        case .vietnamese: "🇻🇳"
        }
    }
}
