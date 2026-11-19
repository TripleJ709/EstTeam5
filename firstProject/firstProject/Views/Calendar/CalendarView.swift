import SwiftUI

/// 월간 달력을 표시하고 날짜를 선택하는 뷰입니다.
struct CalendarView: View {
    /// 표시할 달에 속한 날짜입니다.
    let month: Date
    /// 마커 계산에 사용하는 회고 목록입니다.
    let retrospectives: [Retrospective]
    /// 선택된 날짜입니다. 날짜를 누르면 갱신됩니다.
    @Binding var selectedDate: Date
    /// 오늘로 간주할 날짜입니다. 기본값은 현재 시각입니다.
    var today: Date = .now
    /// 앱 설치 날짜입니다. 기본값은 `AppConfig.installDate`입니다.
    var installDate: Date = AppConfig.installDate

    /// 한국어 로케일을 적용한 `Calendar`입니다.
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = .korean
        return calendar
    }

    /// 7개의 유연한 열로 구성된 그리드 설정입니다.
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    /// 화면 구성
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

    /// 요일 머리글 행입니다. 달력의 `firstWeekday`에 맞춰 순서를 정렬합니다.
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

    /// 표시할 달이 포함된 첫 주의 시작부터 마지막 주의 끝까지의 날짜 목록입니다. 계산에 실패하면 빈 배열입니다.
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
    /// 표시 중인 달이 아니면 `none`, 해당 날짜에 회고가 있으면 가장 최근에 작성한 회고의 감정, 오늘 이전이고 설치 날짜 이후이면 `missed`, 그 외에는 `none`입니다.
    ///
    /// - Parameter date: 마커를 결정할 날짜입니다.
    /// - Returns: 날짜에 표시할 마커입니다.
    private func marker(for date: Date) -> DayCell.Marker {
        guard calendar.isDate(date, equalTo: month, toGranularity: .month) else { return .none }
        if let latest = Retrospective.latest(in: retrospectives, on: date, calendar: calendar) {
            return .emotion(latest.emotion)
        }
        let day = calendar.startOfDay(for: date)
        if day < calendar.startOfDay(for: today), day >= calendar.startOfDay(for: installDate) {
            return .missed
        }
        return .none
    }
}

/// 달력의 날짜 칸 하나를 그리는 뷰입니다.
private struct DayCell: View {
    /// 날짜 칸에 표시되는 마커 종류입니다.
    enum Marker: Equatable { case none, missed, emotion(Emotion) }

    /// 칸이 나타내는 날짜입니다.
    let date: Date
    /// 날짜의 일(day) 숫자입니다.
    let day: Int
    /// 표시 중인 달 밖의 날짜인지 여부입니다. `true`이면 비활성화되고 흐리게 표시됩니다.
    let isOutside: Bool
    /// 선택된 날짜인지 여부입니다.
    let isSelected: Bool
    /// 오늘인지 여부입니다.
    let isToday: Bool
    /// 칸에 표시할 마커입니다.
    let marker: Marker
    /// 칸을 눌렀을 때 호출되는 동작입니다.
    let action: () -> Void

    /// 칸의 높이이며 글자 크기 설정에 따라 조정됩니다.
    @ScaledMetric(relativeTo: .body) private var cellHeight = 72
    /// 마커의 크기이며 글자 크기 설정에 따라 조정됩니다.
    @ScaledMetric(relativeTo: .body) private var markerSize = 34

    /// 선택되었거나 오늘인 날짜인지 여부입니다.
    private var isEmphasized: Bool { isSelected || isToday }

    /// 화면 구성
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

    /// 마커 종류에 따라 감정 오라, 점선 원, 빈 공간 중 하나를 그립니다.
    @ViewBuilder
    private var markerView: some View {
        switch marker {
        case .emotion(let emotion):
            EmotionAuraView(emotion: emotion, size: markerSize)
        case .missed:
            Circle()
                .strokeBorder(Color.borderDashed, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                .frame(width: markerSize, height: markerSize)
        case .none:
            Color.clear.frame(width: markerSize, height: markerSize)
        }
    }

    /// 날짜, 오늘 여부, 감정 이름 또는 기록 없음을 조합한 접근성 레이블입니다.
    private var accessibilityText: String {
        let dateText = (isToday ? "오늘, " : "")
            + date.formatted(.dateTime.month().day().locale(.korean))
        switch marker {
        case .emotion(let emotion): return "\(dateText), \(emotion.displayName)"
        case .missed: return "\(dateText), 기록 없음"
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
