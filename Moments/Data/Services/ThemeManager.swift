import SwiftUI

@Observable
@MainActor
final class ThemeManager {
    static let shared = ThemeManager()

    private static let themeKey = "appTheme"

    private(set) var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: Self.themeKey)
        }
    }

    var colorScheme: ColorScheme? {
        currentTheme.colorScheme
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: Self.themeKey),
           let theme = AppTheme(rawValue: saved) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }

    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
}
