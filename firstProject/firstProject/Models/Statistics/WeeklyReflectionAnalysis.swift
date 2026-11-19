import Foundation

/// 주간 회고 분석 결과입니다. 응답 데이터에서 디코딩하는 모델입니다.
struct WeeklyReflectionAnalysis: Equatable, Sendable, Decodable {
    /// 회고에서 확인되는 주요 사건과 사실입니다.
    let facts: String
    /// 감정 흐름에 대한 설명입니다.
    let emotionalFlow: String
    /// 좋았던 점입니다.
    let positives: String
    /// 아쉽거나 마음 쓰였던 점입니다.
    let regrets: String
    /// 다음을 위한 해결 방법이나 마음가짐입니다.
    let solutions: String
    /// 한 주 전체의 요약입니다.
    let summary: String

    /// 화면에 보여줄 사고 단계 하나입니다.
    struct ThinkingStep: Identifiable, Equatable, Sendable {
        /// 단계의 식별자입니다.
        let id: String
        /// 단계의 제목입니다.
        let title: String
        /// 단계의 내용입니다.
        let content: String
    }

    /// 분석 결과를 화면 표시 순서대로 정리한 사고 단계 목록입니다.
    ///
    /// '일어난 일', '마음의 흐름', '좋았던 순간', '마음 쓰인 일', '작은 힌트', '이번 주 한줄' 순서의 6단계입니다.
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
