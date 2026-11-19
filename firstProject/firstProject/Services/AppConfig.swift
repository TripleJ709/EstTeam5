import Foundation

/// 앱 전역 설정 값을 제공합니다.
///
/// OpenAI 호출에 필요한 API 키 조회, 모델 이름, 설치 날짜를 다룹니다.
enum AppConfig {
    /// Info.plist에서 API 키를 읽을 때 사용하는 키 이름입니다.
    static let apiKeyInfoKey = "OPENAI_API_KEY"
    /// OpenAI 요청에 사용하는 모델 이름입니다.
    static let openAIModel = "gpt-6-luna"
    /// Info.plist에서 읽어 온 OpenAI API 키입니다.
    ///
    /// 값이 없거나 유효하지 않으면 `nil`입니다. 유효성 판단은 `apiKey(from:)`을 따릅니다.
    static var openAIAPIKey: String? {
        apiKey(from: Bundle.main.object(forInfoDictionaryKey: apiKeyInfoKey))
    }

    /// 앱을 처음 사용한 날짜(해당 날의 시작 시각)입니다.
    ///
    /// `UserDefaults`의 `installDate` 키에 저장된 값을 반환합니다. 저장된 값이 없으면 오늘 0시를 저장한 뒤 그 값을 반환합니다.
    static var installDate: Date {
        let key = "installDate"
        if let saved = UserDefaults.standard.object(forKey: key) as? Date { return saved }
        let start = Calendar.current.startOfDay(for: .now)
        UserDefaults.standard.set(start, forKey: key)
        return start
    }

    /// Info.plist에서 읽은 원시 값을 API 키 문자열로 변환합니다.
    ///
    /// 문자열 앞뒤의 공백과 줄바꿈을 제거한 뒤, 비어 있거나 `$(`로 시작하거나 `sk-your-`로 시작하면 `nil`을 반환합니다.
    ///
    /// - Parameter rawValue: Info.plist에서 읽은 원시 값입니다.
    /// - Returns: 유효한 API 키 문자열이며, 유효하지 않으면 `nil`입니다.
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
