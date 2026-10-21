import Foundation

@Observable
@MainActor
final class LanguageManager {
    static let shared = LanguageManager()

    private static let languageKey = "appLanguage"

    private(set) var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Self.languageKey)
            UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        }
    }

    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: Self.languageKey),
           let language = AppLanguage(rawValue: saved) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = .english
        }
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }
}
