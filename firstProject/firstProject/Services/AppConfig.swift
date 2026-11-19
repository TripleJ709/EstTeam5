import Foundation

/// 앱 설정 값을 모아 둔 곳입니다. OpenAI 설정과 설치일을 다룹니다.
enum AppConfig {
    /// Info.plist에서 API 키를 읽을 때 쓰는 키 이름입니다.
    static let apiKeyInfoKey = "OPENAI_API_KEY"
    /// OpenAI 호출에 쓰는 모델 이름입니다.
    static let openAIModel = "gpt-6-luna"
    /// OpenAI API 키입니다.
    ///
    /// `Secrets.xcconfig`에 적은 값이 빌드 때 Info.plist로 전달됩니다.
    /// 키가 없거나 예시 값이면 `nil`입니다.
    static var openAIAPIKey: String? {
        apiKey(from: Bundle.main.object(forInfoDictionaryKey: apiKeyInfoKey))
    }

    /// 앱을 처음 실행한 날(그날 0시)입니다.
    ///
    /// 처음 부르면 오늘 날짜를 저장하고, 그 뒤로는 저장된 값을 돌려줍니다.
    /// 달력에서 설치 전 날짜와 기록을 놓친 날을 구분할 때 씁니다.
    static var installDate: Date {
        let key = "installDate"
        if let saved = UserDefaults.standard.object(forKey: key) as? Date { return saved }
        let start = Calendar.current.startOfDay(for: .now)
        UserDefaults.standard.set(start, forKey: key)
        return start
    }

    /// 설정에서 읽은 값이 쓸 수 있는 API 키인지 확인합니다.
    ///
    /// - Parameter rawValue: Info.plist에서 읽은 값.
    /// - Returns: 앞뒤 공백을 없앤 키. 문자열이 아니거나, 비었거나, 치환되지 않은 `$(...)` 값이거나, 예시 값(`sk-your-`로 시작)이면 `nil`입니다.
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
