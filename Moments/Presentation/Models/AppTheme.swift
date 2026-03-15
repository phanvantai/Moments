import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            String(localized: "theme.system", bundle: LanguageManager.shared.bundle)
        case .light:
            String(localized: "theme.light", bundle: LanguageManager.shared.bundle)
        case .dark:
            String(localized: "theme.dark", bundle: LanguageManager.shared.bundle)
        }
    }

    var iconName: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
