import Foundation

/// 회고 목록에서 날짜별·월별로 묶어 볼 때 쓰는 계산.
/// `Calendar`를 바꿔 끼울 수 있어 날짜를 고정한 테스트가 가능하다.
extension Retrospective {
    /// `month`가 속한 달의 회고만 골라낸다.
    static func inMonth(
        _ items: [Retrospective],
        of month: Date,
        calendar: Calendar = .current
    ) -> [Retrospective] {
        items.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }

    /// 같은 날 기록이 여러 개면 가장 최근에 작성한 기록을 돌려준다.
    static func latest(
        in items: [Retrospective],
        on date: Date,
        calendar: Calendar = .current
    ) -> Retrospective? {
        items
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .max { $0.createdAt < $1.createdAt }
    }

    /// 가장 많이 기록된 감정. 동률이면 `Emotion` 선언 순서가 앞선 감정을 고른다.
    static func topEmotion(in items: [Retrospective]) -> Emotion? {
        guard !items.isEmpty else { return nil }
        let counts = Dictionary(grouping: items, by: \.emotion).mapValues(\.count)
        return Emotion.allCases.max { (counts[$0] ?? 0) < (counts[$1] ?? 0) }
    }

    /// "이번 달은 기쁨이 가장 많았어요 · 13개의 기록"
    static func monthSummary(
        of items: [Retrospective],
        month: Date,
        calendar: Calendar = .current
    ) -> String {
        let monthItems = inMonth(items, of: month, calendar: calendar)
        guard let top = topEmotion(in: monthItems) else { return "이번 달은 아직 기록이 없어요" }
        return "이번 달은 \(top.displayName)\(top.subjectParticle) 가장 많았어요 · \(monthItems.count)개의 기록"
    }
}
