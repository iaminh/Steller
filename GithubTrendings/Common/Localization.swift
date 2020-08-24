import Foundation

class Localization {
    enum Language: String {
        // Add more languages if needed
        case english = "en"
        
        init(locale: Locale) {
            guard let languageCode = locale.languageCode else {
                self = .english
                return
            }
            
            switch languageCode {
            default:
                self = .english
            }
        }
    }
    static let shared = Localization()

    lazy var translations: [String: String] = {
        return generateTranslations()
    }()

    private var languageResources: Data? {
        let currentLanguage = Language(locale: Locale.current)
       
        let fileName = "strings_" + currentLanguage.rawValue
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: ".json") else { return nil }
        do {
            return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        } catch {
            log.message("Error loading json file: \(error.localizedDescription)")
        }

        return nil
    }

    private func generateTranslations() -> [String: String] {
        do {
            guard let data = languageResources else {
                log.message("Error loading language resources")
                return [:]
            }
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: String] ?? [:]
        } catch {
            log.message(error.localizedDescription)
        }

        return [:]
    }
}

extension String {
    var localized: String {
        return Localization.shared.translations[self] ?? self
    }

    func localize(with values: [String]) -> String {
        let localized = Localization.shared.translations[self] ?? self

        return values.enumerated()
            .reduce(localized) { (previous, element) in
                previous.replacingOccurrences(of: "$\(element.offset)", with: element.element)
        }
    }
}
