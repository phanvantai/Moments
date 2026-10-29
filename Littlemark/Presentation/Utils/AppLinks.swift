import Foundation

/// Pages on the Littlemark site (`littlemark-landing/`), opened in the app language.
enum AppLinks {
    private static let site = URL(string: "https://littlemark.taiphanvan.dev")!

    static func privacyPolicy(language: AppLanguage) -> URL {
        page("privacy.html", language: language)
    }

    static func support(language: AppLanguage) -> URL {
        page("support.html", language: language)
    }

    private static func page(_ name: String, language: AppLanguage) -> URL {
        let url = site.appendingPathComponent(name)
        guard language != .english else { return url }
        return url.appending(queryItems: [URLQueryItem(name: "lang", value: language.rawValue)])
    }
}
