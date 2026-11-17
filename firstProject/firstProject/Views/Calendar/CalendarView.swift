import SwiftUI

/// 월간 감정 달력 (Figma "제안 A · 회고 달력")
struct CalendarView: View {
    /// 표시할 달에 포함된 임의의 날짜
    let month: Date
    let retrospectives: [Retrospective]
    @Binding var selectedDate: Date

    private var calendar: Calendar { .current }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)

    var body: some View {
        VStack(spacing: 4) {
            weekdayHeader
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(days, id: \.self) { date in
                    DayCell(
                        date: date,
                        day: calendar.component(.day, from: date),
                        state: state(for: date),
                        emotion: emotion(on: date)
                    ) {
                        selectedDate = date
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.card))
    }

    private var weekdayHeader: some View {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1
        let ordered = Array(symbols[first...] + symbols[..<first])
        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(ordered.indices, id: \.self) { index in
                Text(ordered[index])
                    .font(.caption)
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

    private func state(for date: Date) -> DayCell.State {
        guard calendar.isDate(date, equalTo: month, toGranularity: .month) else { return .outside }
        if calendar.isDate(date, inSameDayAs: selectedDate) { return .selected }
        if emotion(on: date) != nil { return .recorded }
        if date < calendar.startOfDay(for: .now) { return .missed }
        return .empty
    }
}

// MARK: - Day cell

private struct DayCell: View {
    enum State { case empty, recorded, missed, selected, outside }

    let date: Date
    let day: Int
    let state: State
    let emotion: Emotion?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(state == .selected ? .body.weight(.medium) : .callout)
                    .foregroundStyle(FeeloColor.textPrimary)
                    .opacity(state == .outside ? 0.35 : 1)
                marker
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                state == .selected ? FeeloColor.bgSelected : .clear,
                in: RoundedRectangle(cornerRadius: FeeloRadius.cell)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(state == .outside)
        .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private var marker: some View {
        if let emotion, state == .recorded || state == .selected {
            EmotionAuraView(emotion: emotion, size: 28)
        } else if state == .missed {
            Circle()
                .strokeBorder(FeeloColor.borderDashed, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                .frame(width: 28, height: 28)
        } else {
            Color.clear.frame(width: 28, height: 28)
        }
    }

    private var accessibilityText: String {
        let dateText = date.formatted(.dateTime.month().day().locale(Locale(identifier: "ko_KR")))
        if let emotion, state == .recorded || state == .selected {
            return "\(dateText), \(emotion.displayName)"
        }
        return state == .missed ? "\(dateText), 기록 없음" : dateText
    }
}

#Preview {
    @Previewable @State var selected = Date.now
    CalendarView(month: .now, retrospectives: [], selectedDate: $selected)
        .padding(16)
        .background(FeeloColor.bgApp)
}
