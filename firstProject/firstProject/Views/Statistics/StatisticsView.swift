import SwiftData
import SwiftUI

struct StatisticsView: View {
    @Query(sort: \Retrospective.date)
    private var retrospectives: [Retrospective]

    @State private var period: Period = .month
    @State private var anchorDate = Date.now

    private var calendar: Calendar { .current }
    private static let locale = Locale(identifier: "ko_KR")
    private static let emptyMessage = "회고를 남기면 감정 흐름과 분포가 채워져요"

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

        var recordCountLabel: String {
            switch self {
            case .week: "이번 주 기록"
            case .month: "이번 달 기록"
            }
        }

        var emptyTitle: String {
            switch self {
            case .week: "이 주에는 기록이 없어요"
            case .month: "이 달에는 기록이 없어요"
            }
        }

        var feedbackTitle: String {
            switch self {
            case .week: "이번 주의 한마디"
            case .month: "이번 달의 한마디"
            }
        }

        func feedback(for emotion: Emotion) -> String? {
            switch self {
            case .week: emotion.weeklyFeedback
            case .month: emotion.monthlyFeedback
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
                    content
                }
                .padding(.bottom, 24)
            }
            .background { screenBackground }
            .navigationTitle("감정 돌아보기")
        }
        .tint(FeeloColor.tint)
    }

    private var screenBackground: some View {
        ZStack(alignment: .top) {
            FeeloColor.bgApp

            if let top = emotionCounts.first?.emotion {
                EmotionWash(emotion: top, opacity: 0.55, blur: 30)
                    .scaleEffect(1.8)
                    .offset(y: 160)
                    .animation(.easeInOut(duration: 0.25), value: top)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var content: some View {
        if let top = emotionCounts.first?.emotion {
            distributionSection(highlighted: top)
            if let message = period.feedback(for: top), !message.isEmpty {
                StatisticsFeedbackCard(emotion: top, title: period.feedbackTitle, message: message)
                    .padding(.horizontal, 16)
            }
        } else {
            StatisticsEmptyState(title: period.emptyTitle, message: Self.emptyMessage)
                .padding(.horizontal, 16)
        }
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

    private var periodTitle: String {
        switch period {
        case .month:
            return anchorDate.formatted(.dateTime.year().month(.wide).locale(Self.locale))
        case .week:
            guard let first = periodDays.first, let last = periodDays.last else { return "" }
            let startStyle = Date.FormatStyle.dateTime.month().day().locale(Self.locale)
            let endStyle = calendar.isDate(first, equalTo: last, toGranularity: .month)
                ? Date.FormatStyle.dateTime.day().locale(Self.locale)
                : startStyle
            return "\(first.formatted(startStyle)) – \(last.formatted(endStyle))"
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
            StatCard(label: period.recordCountLabel) {
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

    private var emotionDistribution: [(emotion: Emotion, count: Int)] {
        Emotion.allCases.map { emotion in
            (emotion, emotionCounts.first { $0.emotion == emotion }?.count ?? 0)
        }
    }

    private func distributionSection(highlighted: Emotion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("감정 분포")
            EmotionBarChart(items: emotionDistribution, highlighted: highlighted)
        }
        .padding(.horizontal, 16)
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
        .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.summary))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: Retrospective.self, inMemory: true)
}
