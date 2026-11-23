import SwiftUI

/// 한 달치 날짜를 7열 격자로 보여주고, 날짜별 감정 오로라를 표시하는 달력입니다.
struct CalendarView: View {
    /// 표시할 달에 속한 날짜입니다.
    let month: Date
    /// 감정 표시를 찾을 회고 목록입니다.
    let retrospectives: [Retrospective]
    /// 현재 선택된 날짜입니다. 날짜를 누르면 그 날짜로 바뀝니다.
    @Binding var selectedDate: Date
    /// 오늘 날짜입니다. 기본값은 `.now`입니다.
    var today: Date = .now

    /// 현재 캘린더에 한국어 로케일을 지정한 캘린더입니다.
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = .korean
        return calendar
    }

    /// 7개의 균등 너비 열로 이루어진 격자 열 설정입니다.
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    /// 화면 구성: 요일 헤더와 날짜 격자를 카드 배경 위에 배치하며, 글씨 크기는 `xxxLarge`까지로 제한합니다.
    var body: some View {
        VStack(spacing: 8) {
            weekdayHeader
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days, id: \.self) { date in
                    DayCell(
                        date: date,
                        day: calendar.component(.day, from: date),
                        isOutside: !calendar.isDate(date, equalTo: month, toGranularity: .month),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDate(date, inSameDayAs: today),
                        marker: marker(for: date)
                    ) {
                        selectedDate = date
                    }
                }
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 10)
        .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 28))
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    /// 캘린더의 한 주 시작 요일부터 순서대로 나열한 요일 약어 헤더입니다.
    private var weekdayHeader: some View {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1
        let ordered = Array(symbols[first...] + symbols[..<first])
        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(ordered.indices, id: \.self) { index in
                Text(ordered[index])
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
                    .frame(height: 20)
            }
        }
        .accessibilityHidden(true)
    }

    /// 표시할 달이 포함된 첫째 주의 시작부터 마지막 주의 끝까지의 날짜 목록입니다. 계산에 실패하면 빈 배열입니다.
    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: monthInterval.end),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: lastDay) else {
            return []
        }
        return calendar.days(in: DateInterval(start: firstWeek.start, end: lastWeek.end))
    }

    /// 날짜에 표시할 마커를 결정합니다.
    ///
    /// 표시 중인 달에 속한 날짜이고 해당 날짜의 회고가 있으면 가장 최근에 만든 회고의 감정을 사용합니다.
    ///
    /// - Parameter date: 마커를 확인할 날짜입니다.
    /// - Returns: 감정 마커이며, 달 밖의 날짜이거나 회고가 없으면 `.none`입니다.
    private func marker(for date: Date) -> DayCell.Marker {
        guard calendar.isDate(date, equalTo: month, toGranularity: .month) else { return .none }
        if let latest = Retrospective.latest(in: retrospectives, on: date, calendar: calendar) {
            return .emotion(latest.emotion)
        }
        return .none
    }
}

/// 달력의 날짜 한 칸을 그리는 버튼 뷰입니다.
private struct DayCell: View {
    /// 날짜 칸에 표시할 마커 종류입니다. `none`은 마커 없음, `emotion`은 해당 감정의 오로라 표시입니다.
    enum Marker: Equatable { case none, emotion(Emotion) }

    /// 이 칸이 나타내는 날짜입니다.
    let date: Date
    /// 표시할 일(day) 숫자입니다.
    let day: Int
    /// 표시 중인 달 밖의 날짜인지 여부입니다. `true`이면 흐리게 표시하고 비활성화합니다.
    let isOutside: Bool
    /// 선택된 날짜인지 여부입니다.
    let isSelected: Bool
    /// 오늘인지 여부입니다.
    let isToday: Bool
    /// 날짜 아래에 표시할 마커입니다.
    let marker: Marker
    /// 칸을 눌렀을 때 실행할 동작입니다.
    let action: () -> Void

    /// 글씨 크기에 비례해 조절되는 칸 높이입니다. 기본값은 72입니다.
    @ScaledMetric(relativeTo: .body) private var cellHeight = 72
    /// 글씨 크기에 비례해 조절되는 마커 크기입니다. 기본값은 34입니다.
    @ScaledMetric(relativeTo: .body) private var markerSize = 34

    /// 선택되었거나 오늘이면 `true`입니다.
    private var isEmphasized: Bool { isSelected || isToday }

    /// 화면 구성: 날짜 숫자와 마커를 세로로 쌓은 버튼이며, 선택된 날짜는 선택 배경을 칠합니다.
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(isEmphasized ? .body.weight(.medium) : .callout)
                    .foregroundStyle(isEmphasized ? Color.tintPrimary : Color.textPrimary)
                    .opacity(isOutside ? 0.35 : 1)
                markerView
            }
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity)
            .frame(height: cellHeight)
            .background(
                isSelected && !isOutside ? Color.bgSelected : .clear,
                in: RoundedRectangle(cornerRadius: 14)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isOutside)
        .accessibilityLabel(accessibilityText)
    }

    /// 마커에 따라 감정 오로라 또는 빈 공간을 보여주는 뷰입니다.
    @ViewBuilder
    private var markerView: some View {
        switch marker {
        case .emotion(let emotion):
            EmotionAuraView(emotion: emotion, size: markerSize)
        case .none:
            Color.clear.frame(width: markerSize, height: markerSize)
        }
    }

    /// VoiceOver에 읽어줄 문구입니다. 오늘이면 "오늘, "을 앞에 붙이고, 감정 마커가 있으면 감정 이름을 뒤에 붙입니다.
    private var accessibilityText: String {
        let dateText = (isToday ? "오늘, " : "")
            + date.formatted(.dateTime.month().day().locale(.korean))
        switch marker {
        case .emotion(let emotion): return "\(dateText), \(emotion.displayName)"
        case .none: return dateText
        }
    }
}

#Preview {
    @Previewable @State var selected = Date.now
    CalendarView(month: .now, retrospectives: [], selectedDate: $selected)
        .padding(16)
        .background(Color.bgApp)
}
