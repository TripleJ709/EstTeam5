import Foundation

/// 회고 내용으로부터 추천된 감정과 그 이유입니다.
///
/// AI 서버의 응답을 디코딩하는 데 사용합니다.
nonisolated struct EmotionRecommendation: Decodable, Equatable {
    /// 추천된 감정입니다.
    let emotion: Emotion
    /// 감정을 추천한 이유입니다.
    let reason: String
}

/// 회고 내용을 읽고 어울리는 감정을 AI 서버에서 추천받는 서비스입니다.
///
/// 프롬프트와 응답 형식은 서버(`server/functions/prompts.js`)에 있습니다.
struct EmotionRecommender {
    /// 오류 메시지(`AIServerError.userMessage(for:)`)에 사용하는 기능 이름입니다.
    static let feature = "추천"

    /// AI 서버에 요청을 보내는 클라이언트입니다.
    private let client = AIServerClient()

    /// 회고 내용에 어울리는 감정 하나와 그 이유를 추천받습니다.
    ///
    /// 제한 시간 30초로 요청을 보내며, 응답의 이유(reason)는 앞뒤 공백과 줄바꿈을 제거해서 반환합니다.
    ///
    /// - Parameter content: 감정을 분석할 회고 본문입니다.
    /// - Returns: 추천된 감정과 이유입니다.
    /// - Throws: `AIServerClient.send`가 던지는 오류(`AIServerError` 또는 `CancellationError`)를 그대로 던집니다.
    func recommend(for content: String) async throws -> EmotionRecommendation {
        let recommendation: EmotionRecommendation = try await client.send(
            functionName: "recommendEmotion",
            content: content,
            timeout: 30
        )
        let trimmedReason = recommendation.reason.trimmingCharacters(in: .whitespacesAndNewlines)
        return EmotionRecommendation(emotion: recommendation.emotion, reason: trimmedReason)
    }
}
