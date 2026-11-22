import SwiftUI

struct CalendarView: View {
    let month: Date
    let retrospectives: [Retrospective]
    @Binding var selectedDate: Date
    var today: Date = .now

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = .korean
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
        .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 28))
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

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

    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: monthInterval.end),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: lastDay) else {
            return []
        }
        return calendar.days(in: DateInterval(start: firstWeek.start, end: lastWeek.end))
    }

    private func marker(for date: Date) -> DayCell.Marker {
        guard calendar.isDate(date, equalTo: month, toGranularity: .month) else { return .none }
        if let latest = Retrospective.latest(in: retrospectives, on: date, calendar: calendar) {
            return .emotion(latest.emotion)
        }
        return .none
    }
}

private struct DayCell: View {
    enum Marker: Equatable { case none, emotion(Emotion) }

    let date: Date
    let day: Int
    let isOutside: Bool
    let isSelected: Bool
    let isToday: Bool
    let marker: Marker
    let action: () -> Void

    @ScaledMetric(relativeTo: .body) private var cellHeight = 72
    @ScaledMetric(relativeTo: .body) private var markerSize = 34

    private var isEmphasized: Bool { isSelected || isToday }

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

    @ViewBuilder
    private var markerView: some View {
        switch marker {
        case .emotion(let emotion):
            EmotionAuraView(emotion: emotion, size: markerSize)
        case .none:
            Color.clear.frame(width: markerSize, height: markerSize)
        }
    }

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
