import Foundation

/// 앱 설정 값을 모아 둔 네임스페이스입니다.
///
/// 인스턴스를 만들 수 없는 열거형이며, 정적 멤버로만 사용합니다.
enum AppConfig {
    /// Info.plist에서 OpenAI API 키를 읽을 때 사용하는 키 이름입니다.
    static let apiKeyInfoKey = "OPENAI_API_KEY"
    /// OpenAI 요청에 사용하는 모델 이름입니다.
    static let openAIModel = "gpt-6-luna"
    /// Info.plist에 설정된 OpenAI API 키입니다.
    ///
    /// 값이 없거나 유효하지 않으면 `nil`입니다. 유효성 판단은 `apiKey(from:)`가 합니다.
    static var openAIAPIKey: String? {
        apiKey(from: Bundle.main.object(forInfoDictionaryKey: apiKeyInfoKey))
    }

    /// Info.plist에서 읽은 원시 값을 유효한 API 키 문자열로 변환합니다.
    ///
    /// 문자열이 아니거나, 앞뒤 공백과 줄바꿈을 제거한 결과가 비어 있거나, `$(`로 시작하거나,
    /// `sk-your-`로 시작하는 경우에는 키가 설정되지 않은 것으로 봅니다.
    ///
    /// - Parameter rawValue: Info.plist에서 읽은 원시 값입니다.
    /// - Returns: 앞뒤 공백을 제거한 API 키 문자열입니다. 유효하지 않으면 `nil`입니다.
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
