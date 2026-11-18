import Foundation

struct WeeklyReflectionAnalysis: Equatable, Sendable {
    let facts: String
    let emotionalFlow: String
    let positives: String
    let regrets: String
    let solutions: String
    let summary: String

    struct ThinkingStep: Identifiable, Equatable, Sendable {
        let id: String
        let title: String
        let content: String
    }

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
