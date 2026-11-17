import Foundation

/// 회고 목록 화면의 날짜·집계 계산을 모아 둔 순수 로직.
/// 화면(View)과 분리되어 있어 `Calendar`를 바꿔 끼우면 단위 테스트가 가능하다.
struct RetrospectiveCalculator {
    var calendar: Calendar = .current

    /// `month`가 속한 달의 회고만 골라낸다.
    func retrospectives(_ items: [Retrospective], inMonthOf month: Date) -> [Retrospective] {
        items.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }

    /// 같은 날 기록이 여러 개면 가장 최근에 작성한 기록을 돌려준다.
    func latest(in items: [Retrospective], on date: Date) -> Retrospective? {
        items
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .max { $0.createdAt < $1.createdAt }
    }

    /// 가장 많이 기록된 감정. 동률이면 `Emotion` 선언 순서가 앞선 감정을 고른다.
    func topEmotion(in items: [Retrospective]) -> Emotion? {
        guard !items.isEmpty else { return nil }
        let counts = Dictionary(grouping: items, by: \.emotion).mapValues(\.count)
        return Emotion.allCases.max { (counts[$0] ?? 0) < (counts[$1] ?? 0) }
    }

    /// "이번 달은 기쁨이 가장 많았어요 · 13개의 기록"
    func monthSummary(of items: [Retrospective], month: Date) -> String {
        let monthItems = retrospectives(items, inMonthOf: month)
        guard let top = topEmotion(in: monthItems) else { return "이번 달은 아직 기록이 없어요" }
        return "이번 달은 \(top.displayName)\(top.subjectParticle) 가장 많았어요 · \(monthItems.count)개의 기록"
    }

    /// `month`에서 `value`개월 이동한 달과, 그 달에서 기본으로 선택할 날짜.
    /// 이동한 달이 이번 달이면 오늘, 아니면 그 달 1일을 선택한다.
    func movedMonth(from month: Date, by value: Int, now: Date = .now) -> (month: Date, selectedDate: Date)? {
        guard let moved = calendar.date(byAdding: .month, value: value, to: month),
              let start = calendar.dateInterval(of: .month, for: moved)?.start else { return nil }
        let isCurrentMonth = calendar.isDate(moved, equalTo: now, toGranularity: .month)
        return (moved, isCurrentMonth ? now : start)
    }
}

extension Emotion {
    /// 받침 유무에 따라 주격 조사 "이/가"를 돌려준다.
    var subjectParticle: String {
        guard let last = displayName.unicodeScalars.last,
              (0xAC00...0xD7A3).contains(last.value) else { return "이" }
        return (last.value - 0xAC00) % 28 == 0 ? "가" : "이"
    }
}
