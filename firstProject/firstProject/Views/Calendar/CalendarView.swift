import SwiftUI

/// 월간 감정 달력 (Figma "제안 A · 회고 달력")
struct CalendarView: View {
    /// 표시할 달에 포함된 임의의 날짜
    let month: Date
    let retrospectives: [Retrospective]
    @Binding var selectedDate: Date
    var today: Date = .now
    /// 이 날짜 이전에는 "기록 안 한 날" 점선을 그리지 않는다.
    var installDate: Date = AppConfig.installDate

    /// 요일 기호를 한글(일 월 화…)로 보여주기 위해 로케일을 고정한다.
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

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
        .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.calendar))
    }

    private var weekdayHeader: some View {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1
        let ordered = Array(symbols[first...] + symbols[..<first])
        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(ordered.indices, id: \.self) { index in
                Text(ordered[index])
                    .font(.system(size: 13, weight: .medium))
                    .tracking(-0.08)
                    .foregroundStyle(FeeloColor.textSecondary)
                    .frame(height: 20)
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: - Data

    /// 달력에 그릴 날짜. 첫 주와 마지막 주의 앞뒤는 이웃 달 날짜로 채운다.
    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: monthInterval.end),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: lastDay) else {
            return []
        }
        var result: [Date] = []
        var cursor = firstWeek.start
        while cursor < lastWeek.end {
            result.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    /// 같은 날 기록이 여러 개면 가장 최근에 작성한 기록의 감정을 보여준다.
    private func emotion(on date: Date) -> Emotion? {
        retrospectives
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .max { $0.createdAt < $1.createdAt }?
            .emotion
    }

    /// 기록이 있으면 감정 구슬, 사용 시작일 이후의 지난 날에 기록이 없으면 점선, 그 외는 비워 둔다.
    private func marker(for date: Date) -> DayCell.Marker {
        guard calendar.isDate(date, equalTo: month, toGranularity: .month) else { return .none }
        if let emotion = emotion(on: date) { return .emotion(emotion) }
        let day = calendar.startOfDay(for: date)
        if day < calendar.startOfDay(for: today), day >= calendar.startOfDay(for: installDate) {
            return .missed
        }
        return .none
    }
}

// MARK: - Day cell

private struct DayCell: View {
    enum Marker: Equatable { case none, missed, emotion(Emotion) }

    let date: Date
    let day: Int
    let isOutside: Bool
    let isSelected: Bool
    let isToday: Bool
    let marker: Marker
    let action: () -> Void

    /// 선택한 날과 오늘은 굵은 Ink 숫자로 보여준다.
    private var isEmphasized: Bool { isSelected || isToday }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(.system(size: isEmphasized ? 17 : 16, weight: isEmphasized ? .medium : .regular))
                    .tracking(isEmphasized ? -0.43 : -0.31)
                    .foregroundStyle(isEmphasized ? FeeloColor.tint : FeeloColor.textPrimary)
                    .opacity(isOutside ? 0.35 : 1)
                markerView
            }
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(
                isSelected && !isOutside ? FeeloColor.bgSelected : .clear,
                in: RoundedRectangle(cornerRadius: FeeloRadius.cell)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isOutside)
        .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private var markerView: some View {
        switch marker {
        case .emotion(let emotion):
            EmotionAuraView(emotion: emotion, size: 34)
        case .missed:
            Circle()
                .strokeBorder(FeeloColor.borderDashed, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                .frame(width: 34, height: 34)
        case .none:
            Color.clear.frame(width: 34, height: 34)
        }
    }

    private var accessibilityText: String {
        let dateText = (isToday ? "오늘, " : "")
            + date.formatted(.dateTime.month().day().locale(Locale(identifier: "ko_KR")))
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
        .background(FeeloColor.bgApp)
}
