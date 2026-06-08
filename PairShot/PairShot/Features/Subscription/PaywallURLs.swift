import Foundation

nonisolated enum PaywallURLs {
    static let baseUrlInfoKey: String = "WebBaseUrl"

    static var privacy: URL {
        url(path: "/privacy")
    }

    static var terms: URL {
        url(path: "/terms")
    }

    private static var isEnglish: Bool {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return Locale(identifier: preferred).language.languageCode?.identifier != "ko"
    }

    static func url(path: String, base: String, isEnglish: Bool) -> URL {
        let suffix = isEnglish ? "/en" : ""
        guard let url = URL(string: base + path + suffix) else {
            fatalError("Invalid PaywallURLs base configuration")
        }
        return url
    }

    static func resolveBase(bundle: Bundle = .main) -> String {
        let raw = bundle.object(forInfoDictionaryKey: baseUrlInfoKey) as? String ?? ""
        return raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func url(path: String) -> URL {
        url(path: path, base: resolveBase(), isEnglish: isEnglish)
    }
}
