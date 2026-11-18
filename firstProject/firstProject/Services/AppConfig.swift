import Foundation

enum AppConfig {
    static let apiKeyInfoKey = "OPENAI_API_KEY"
    static let openAIModel = "gpt-6-luna"
    static var openAIAPIKey: String? {
        apiKey(from: Bundle.main.object(forInfoDictionaryKey: apiKeyInfoKey))
    }

    static var installDate: Date {
        let key = "installDate"
        if let saved = UserDefaults.standard.object(forKey: key) as? Date { return saved }
        let start = Calendar.current.startOfDay(for: .now)
        UserDefaults.standard.set(start, forKey: key)
        return start
    }

    static func apiKey(from rawValue: Any?) -> String? {
        guard let text = (rawValue as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              !text.hasPrefix("$("),
              !text.hasPrefix("sk-your-") else {
            return nil
        }
        return text
    }
}
