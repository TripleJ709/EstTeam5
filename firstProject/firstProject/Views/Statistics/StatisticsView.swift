import Charts
import SwiftData
import SwiftUI

struct StatisticsView: View {
    @Query(sort: \Retrospective.date)
    private var retrospectives: [Retrospective]

    @State private var period: Period = .month
    @State private var anchorDate = Date.now

    private var calendar: Calendar { .current }
    private static let locale = Locale(identifier: "ko_KR")

    enum Period: String, CaseIterable, Identifiable {
        case week = "주간"
        case month = "월간"
        var id: String { rawValue }

        var calendarComponent: Calendar.Component {
            switch self {
            case .week: .weekOfYear
            case .month: .month
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("기간", selection: $period) {
                        ForEach(Period.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)

                    periodNavigation
                    summaryCards
                    flowSection
                    distributionSection
                }
                .padding(.bottom, 24)
            }
            .background(FeeloColor.bgApp.ignoresSafeArea())
            .navigationTitle("통계")
        }
        .tint(FeeloColor.tint)
    }

    private var periodDays: [Date] {
        guard let interval = calendar.dateInterval(of: period.calendarComponent, for: anchorDate) else { return [] }
        var result: [Date] = []
        var cursor = interval.start
        while cursor < interval.end {
            result.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    private var periodRetrospectives: [Retrospective] {
        retrospectives.filter { calendar.isDate($0.date, equalTo: anchorDate, toGranularity: period.calendarComponent) }
    }

    private var emotionCounts: [(emotion: Emotion, count: Int)] {
        let counts = Dictionary(grouping: periodRetrospectives, by: \.emotion).mapValues(\.count)
        return Emotion.allCases
            .compactMap { emotion in counts[emotion].map { (emotion, $0) } }
            .sorted { $0.count > $1.count }
    }

    private func emotion(on day: Date) -> Emotion? {
        periodRetrospectives
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .max { $0.createdAt < $1.createdAt }?
            .emotion
    }

    private var periodTitle: String {
        switch period {
        case .month:
            return anchorDate.formatted(.dateTime.year().month(.defaultDigits).locale(Self.locale))
        case .week:
            guard let first = periodDays.first, let last = periodDays.last else { return "" }
            let style = Date.FormatStyle.dateTime.month().day().locale(Self.locale)
            return "\(first.formatted(style)) ~ \(last.formatted(style))"
        }
    }

    private func moveAnchor(by value: Int) {
        if let moved = calendar.date(byAdding: period.calendarComponent, value: value, to: anchorDate) {
            anchorDate = moved
        }
    }

    private var periodNavigation: some View {
        HStack(spacing: 0) {
            Text(periodTitle)
                .font(.title3.weight(.medium))
                .foregroundStyle(FeeloColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            navigationButton(systemName: "chevron.left", label: "이전", offset: -1)
            navigationButton(systemName: "chevron.right", label: "다음", offset: 1)
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
    }

    private func navigationButton(systemName: String, label: String, offset: Int) -> some View {
        Button {
            moveAnchor(by: offset)
        } label: {
            Image(systemName: systemName)
                .font(.title3.weight(.medium))
                .foregroundStyle(FeeloColor.tint)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(label)
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            StatCard(label: period == .month ? "이번 달 회고" : "이번 주 회고") {
                Text("\(periodRetrospectives.count)건")
            }
            StatCard(label: "가장 많은 감정") {
                if let top = emotionCounts.first {
                    HStack(spacing: 8) {
                        EmotionAuraView(emotion: top.emotion, size: 20)
                        Text("\(top.emotion.displayName) \(top.count)회")
                    }
                } else {
                    Text("-")
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var flowSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle(period == .month ? "한 달 감정 흐름" : "한 주 감정 흐름")

            VStack(alignment: .leading, spacing: 8) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(maximum: 28), spacing: 2), count: 15),
                    alignment: .leading,
                    spacing: 2
                ) {
                    ForEach(periodDays, id: \.self) { day in
                        FlowCell(state: flowState(for: day))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }

                HStack {
                    Text(periodDays.first?.formatted(.dateTime.month().day().locale(Self.locale)) ?? "")
                    Spacer()
                    Text(periodDays.last?.formatted(.dateTime.day().locale(Self.locale)) ?? "")
                }
                .font(.caption2)
                .foregroundStyle(FeeloColor.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 14)
            .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.card))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("감정 흐름")
            .accessibilityValue(flowAccessibilityValue)
        }
        .padding(.horizontal, 16)
    }

    private func flowState(for day: Date) -> FlowCell.CellState {
        if let emotion = emotion(on: day) { return .recorded(emotion) }
        return day > .now ? .future : .missed
    }

    private var flowAccessibilityValue: String {
        guard !emotionCounts.isEmpty else { return "기록 없음" }
        return emotionCounts.map { "\($0.emotion.displayName) \($0.count)회" }.joined(separator: ", ")
    }

    private var distributionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("감정 분포")

            Group {
                if emotionCounts.isEmpty {
                    Text("이 기간에는 기록이 없어요")
                        .font(.subheadline)
                        .foregroundStyle(FeeloColor.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 132)
                } else {
                    HStack(spacing: 20) {
                        donut
                        legend
                    }
                }
            }
            .padding(16)
            .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.card))
        }
        .padding(.horizontal, 16)
    }

    private var donut: some View {
        Chart(emotionCounts, id: \.emotion) { item in
            SectorMark(
                angle: .value("기록", item.count),
                innerRadius: .ratio(0.62),
                angularInset: 1
            )
            .foregroundStyle(item.emotion.auraEnd)
        }
        .frame(width: 132, height: 132)
        .overlay {
            VStack(spacing: 0) {
                Text("\(periodRetrospectives.count)")
                    .font(.title.bold())
                    .foregroundStyle(FeeloColor.textPrimary)
                Text("기록")
                    .font(.footnote)
                    .foregroundStyle(FeeloColor.textSecondary)
            }
        }
        .accessibilityHidden(true)
    }

    private var legend: some View {
        let total = max(periodRetrospectives.count, 1)
        return VStack(spacing: 6) {
            ForEach(emotionCounts, id: \.emotion) { item in
                HStack(spacing: 8) {
                    EmotionAuraView(emotion: item.emotion, size: 10)
                    Text(item.emotion.displayName)
                        .foregroundStyle(FeeloColor.textPrimary)
                    Spacer(minLength: 4)
                    Text("\(item.count)회 · \(Int((Double(item.count) / Double(total) * 100).rounded()))%")
                        .foregroundStyle(FeeloColor.textSecondary)
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(FeeloColor.textSecondary)
            .padding(.horizontal, 16)
            .padding(.top, 8)
    }
}

private struct StatCard<Value: View>: View {
    let label: String
    @ViewBuilder let value: Value

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(FeeloColor.textSecondary)
            value
                .font(.title3.bold())
                .foregroundStyle(FeeloColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.card))
        .accessibilityElement(children: .combine)
    }
}

private struct FlowCell: View {
    enum CellState {
        case recorded(Emotion)
        case missed
        case future
    }

    let state: CellState

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 6)
        switch state {
        case .recorded(let emotion):
            shape.fill(
                RadialGradient(
                    colors: [emotion.auraStart, emotion.auraEnd],
                    center: .center,
                    startRadius: 0,
                    endRadius: 15
                )
            )
        case .missed:
            shape.strokeBorder(FeeloColor.borderDashed, style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
        case .future:
            shape.fill(FeeloColor.bgSelected)
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: Retrospective.self, inMemory: true)
}
