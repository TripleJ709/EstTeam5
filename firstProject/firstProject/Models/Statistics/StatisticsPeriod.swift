import Foundation

/// 통계를 보는 기간 단위입니다. 주간은 일요일부터 토요일까지, 월간은 한 달입니다.
///
/// `rawValue`는 화면 선택기에 보이는 이름입니다.
enum StatisticsPeriod: String, CaseIterable, Identifiable {
    /// 한 주 단위.
    case week = "주간"
    /// 한 달 단위.
    case month = "월간"

    var id: String { rawValue }

    /// 날짜 계산에 쓰는 캘린더 단위입니다.
    var calendarComponent: Calendar.Component {
        switch self {
        case .week: .weekOfYear
        case .month: .month
        }
    }

    /// 기록 건수 카드의 제목입니다. 예: `이번 주 기록`
    var recordCountLabel: String {
        switch self {
        case .week: "이번 주 기록"
        case .month: "이번 달 기록"
        }
    }

    /// 기간 안에 기록이 없을 때 보여 주는 안내 제목입니다.
    var emptyTitle: String {
        switch self {
        case .week: "이 주에는 기록이 없어요"
        case .month: "이 달에는 기록이 없어요"
        }
    }

    /// 한마디 카드의 제목입니다. 예: `이번 주의 한마디`
    var feedbackTitle: String {
        switch self {
        case .week: "이번 주의 한마디"
        case .month: "이번 달의 한마디"
        }
    }

    /// 기간에 맞는 한마디 문구를 돌려줍니다.
    ///
    /// - Parameter emotion: 그 기간에 가장 많이 기록한 감정.
    /// - Returns: 주간이면 `weeklyFeedback`, 월간이면 `monthlyFeedback`.
    func feedback(for emotion: Emotion) -> String {
        switch self {
        case .week: emotion.weeklyFeedback
        case .month: emotion.monthlyFeedback
        }
    }

    /// 기준 날짜가 속한 기간의 모든 날짜를 나열합니다.
    ///
    /// - Parameters:
    ///   - anchor: 기준 날짜.
    ///   - calendar: 날짜 계산에 쓸 캘린더. 기본값은 현재 캘린더입니다.
    /// - Returns: 기간에 속한 날짜 배열.
    func days(of anchor: Date, calendar: Calendar = .current) -> [Date] {
        guard let interval = calendar.dateInterval(of: calendarComponent, for: anchor) else { return [] }
        return calendar.days(in: interval)
    }

    /// 기간을 나타내는 제목을 만듭니다.
    /// 월간은 `2026년 11월`, 주간은 `11월 15일 – 21일`처럼 보입니다.
    /// 주가 두 달에 걸치면 끝 날짜에도 월을 붙입니다.
    ///
    /// - Parameters:
    ///   - anchor: 기준 날짜.
    ///   - calendar: 날짜 계산에 쓸 캘린더. 기본값은 현재 캘린더입니다.
    /// - Returns: 화면에 보여 줄 기간 제목.
    func title(of anchor: Date, calendar: Calendar = .current) -> String {
        switch self {
        case .month:
            return anchor.formatted(.dateTime.year().month(.wide).locale(.korean))
        case .week:
            let periodDays = days(of: anchor, calendar: calendar)
            guard let first = periodDays.first, let last = periodDays.last else { return "" }
            let startStyle = Date.FormatStyle.dateTime.month().day().locale(.korean)
            let endStyle = calendar.isDate(first, equalTo: last, toGranularity: .month)
                ? Date.FormatStyle.dateTime.day().locale(.korean)
                : startStyle
            return "\(first.formatted(startStyle)) – \(last.formatted(endStyle))"
        }
    }

    /// 기준 날짜를 이전 또는 다음 기간으로 옮깁니다.
    ///
    /// - Parameters:
    ///   - anchor: 기준 날짜.
    ///   - value: 옮길 기간 수. 음수면 이전, 양수면 다음입니다.
    ///   - calendar: 날짜 계산에 쓸 캘린더. 기본값은 현재 캘린더입니다.
    /// - Returns: 옮긴 날짜. 계산할 수 없으면 기준 날짜 그대로입니다.
    func moved(_ anchor: Date, by value: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: calendarComponent, value: value, to: anchor) ?? anchor
    }
}
