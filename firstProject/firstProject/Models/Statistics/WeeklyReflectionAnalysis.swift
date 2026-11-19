import Foundation

/// AI가 정리한 주간 회고 리포트입니다. 6단계 사고 모델의 결과를 담습니다.
///
/// OpenAI 응답(JSON)을 그대로 해석해 만듭니다.
struct WeeklyReflectionAnalysis: Equatable, Sendable, Decodable {
    /// 일어난 일. 회고에서 확인되는 주요 사건과 사실입니다.
    let facts: String
    /// 마음의 흐름. 요일별 감정 변화를 회고 내용과 엮은 설명입니다.
    let emotionalFlow: String
    /// 좋았던 순간. 잘 해냈거나 의미 있었던 점입니다.
    let positives: String
    /// 마음 쓰인 일. 아쉽거나 마음에 남은 점입니다.
    let regrets: String
    /// 작은 힌트. 다음 주를 위한 가벼운 실천이나 마음가짐입니다.
    let solutions: String
    /// 이번 주 한줄. 한 주 전체를 정리하는 요약입니다.
    let summary: String

    /// 리포트의 한 단계입니다. 화면에서 제목과 내용을 한 줄씩 보여 줍니다.
    struct ThinkingStep: Identifiable, Equatable, Sendable {
        let id: String
        let title: String
        let content: String
    }

    /// 화면에 차례로 보여 주기 위해 6단계를 순서대로 묶은 목록입니다.
    ///
    /// 순서는 일어난 일, 마음의 흐름, 좋았던 순간, 마음 쓰인 일, 작은 힌트, 이번 주 한줄입니다.
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
