import Foundation

/// 한 주의 회고를 AI 서버에서 분석받는 서비스입니다.
///
/// 프롬프트와 응답 형식은 서버(`server/functions/prompts.js`)에 있습니다.
struct WeeklyReflectionAnalyzer {
    /// 오류 메시지(`AIServerError.userMessage(for:)`)에 사용하는 기능 이름입니다.
    static let feature = "분석"

    /// AI 서버에 요청을 보내는 클라이언트입니다.
    private let client = AIServerClient()

    /// 주간 회고 입력을 분석해 6가지 항목으로 정리한 결과를 반환합니다.
    ///
    /// 제한 시간 60초로 요청을 보냅니다.
    ///
    /// - Parameter input: 분석할 주간 회고 입력입니다.
    /// - Returns: 일어난 일, 마음의 흐름 등을 담은 분석 결과입니다.
    /// - Throws: `AIServerClient.send`가 던지는 오류(`AIServerError` 또는 `CancellationError`)를 그대로 던집니다.
    func analyze(_ input: WeeklyReflectionInput) async throws -> WeeklyReflectionAnalysis {
        try await client.send(
            functionName: "analyzeWeek",
            content: Self.makeUserContent(from: input),
            timeout: 60
        )
    }

    /// 입력으로부터 사용자 메시지 본문을 만듭니다.
    ///
    /// 기간, 기록 건수와 기록한 일수, 가장 많이 선택한 감정(있을 때만), 감정 분포, 요일별 감정 흐름, 회고 기록을 줄 단위로 이어 붙입니다.
    ///
    /// - Parameter input: 주간 회고 입력입니다.
    /// - Returns: AI 서버에 보낼 사용자 메시지 문자열입니다.
    private static func makeUserContent(from input: WeeklyReflectionInput) -> String {
        let weekdayStyle = Date.FormatStyle.dateTime.weekday(.abbreviated).locale(.korean)
        let dateStyle = Date.FormatStyle.dateTime.month().day().weekday(.abbreviated).locale(.korean)

        let counts = Emotion.allCases
            .map { "\($0.displayName) \(input.emotionCounts[$0] ?? 0)회" }
            .joined(separator: ", ")
        let flow = input.dailyEmotions
            .map { "\($0.date.formatted(weekdayStyle)) \($0.emotion.displayName)" }
            .joined(separator: " → ")
        let records = input.entries
            .map { "[\($0.date.formatted(dateStyle)) | 기록 감정: \($0.emotion.displayName)]\n\($0.content)" }
            .joined(separator: "\n\n")

        var lines = [
            "[앱이 계산한 사실 · 숫자와 감정은 이 값을 그대로 사용할 것]",
            "- 기간: \(input.periodTitle)",
            "- 기록: \(input.recordCount)건 (\(input.recordedDayCount)일)"
        ]
        if let top = input.topEmotion {
            lines.append("- 가장 많이 선택한 감정: \(top.displayName) \(input.topEmotionCount)회")
        }
        lines += ["- 감정 분포: \(counts)", "- 요일별 감정 흐름: \(flow)", "", "[회고 기록]", records]
        return lines.joined(separator: "\n")
    }
}
