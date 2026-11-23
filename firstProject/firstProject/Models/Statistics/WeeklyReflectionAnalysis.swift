import Foundation

/// 주간 회고 분석 결과입니다.
///
/// 일어난 일, 감정 흐름, 좋았던 점, 아쉬운 점, 해결책, 요약의 여섯 항목으로 구성됩니다.
struct WeeklyReflectionAnalysis: Equatable, Sendable, Decodable {
    /// 일어난 일입니다.
    let facts: String
    /// 감정의 흐름입니다.
    let emotionalFlow: String
    /// 좋았던 점입니다.
    let positives: String
    /// 아쉽거나 마음 쓰인 점입니다.
    let regrets: String
    /// 다음을 위한 해결책이나 힌트입니다.
    let solutions: String
    /// 전체 요약입니다.
    let summary: String

    /// 화면에 순서대로 보여줄 분석 항목 하나입니다.
    struct ThinkingStep: Identifiable, Equatable, Sendable {
        /// 항목의 식별자입니다.
        let id: String
        /// 항목의 제목입니다.
        let title: String
        /// 항목의 내용입니다.
        let content: String
    }

    /// 분석 결과를 화면 표시 순서대로 나열한 항목 목록입니다.
    ///
    /// 일어난 일, 마음의 흐름, 좋았던 순간, 마음 쓰인 일, 작은 힌트, 이번 주 한줄 순서입니다.
    var thinkingSteps: [ThinkingStep] {
        [
            ThinkingStep(id: "facts", title: "일어난 일", content: facts),
            ThinkingStep(id: "emotionalFlow", title: "마음의 흐름", content: emotionalFlow),
            ThinkingStep(id: "positives", title: "좋았던 순간", content: positives),
            ThinkingStep(id: "regrets", title: "마음 쓰인 일", content: regrets),
            ThinkingStep(id: "solutions", title: "작은 힌트", content: solutions),
            ThinkingStep(id: "summary", title: "이번 주 한줄", content: summary)
        ]
    }
}
