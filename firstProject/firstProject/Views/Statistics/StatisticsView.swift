import SwiftData
import SwiftUI

struct StatisticsView: View {
    @Query(sort: \Retrospective.date)
    private var retrospectives: [Retrospective]

    @State private var period: StatisticsPeriod = .month
    @State private var anchorDate = Date.now
    @State private var weeklyAnalysis = WeeklyAnalysisStore()

    @Environment(\.dynamicTypeSize) private var typeSize
    private static let emptyMessage = "회고를 남기면 감정 흐름과 분포가 채워져요"

    private var periodItems: [Retrospective] {
        Retrospective.inPeriod(retrospectives, period, of: anchorDate)
    }

    private var topEmotion: Emotion? {
        Retrospective.topEmotion(in: periodItems)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("기간", selection: $period) {
                        ForEach(StatisticsPeriod.allCases) { Text($0.rawValue).tag($0) }
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
        .tint(Color.tintPrimary)
        .onChange(of: anchorDate) { weeklyAnalysis.reset() }
        .onChange(of: period) { weeklyAnalysis.reset() }
    }

    private var screenBackground: some View {
        ZStack(alignment: .top) {
            Color.bgApp

            if let top = topEmotion {
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
        if let top = topEmotion {
            distributionSection(highlighted: top)
            StatisticsFeedbackCard(emotion: top, title: period.feedbackTitle, message: period.feedback(for: top))
                .padding(.horizontal, 16)

            if period == .week {
                WeeklyAIReportSection(state: weeklyAnalysis.state, accentEmotion: top) {
                    weeklyAnalysis.analyze(WeeklyReflectionInput(retrospectives: retrospectives, weekOf: anchorDate))
                }
            }
        } else {
            StatisticsEmptyState(title: period.emptyTitle, message: Self.emptyMessage)
                .padding(.horizontal, 16)
        }
    }

    private var periodNavigation: some View {
        HStack(spacing: 0) {
            Text(period.title(of: anchorDate))
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            navigationButton(systemName: "chevron.left", label: "이전", offset: -1)
            navigationButton(systemName: "chevron.right", label: "다음", offset: 1)
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private func navigationButton(systemName: String, label: String, offset: Int) -> some View {
        Button {
            anchorDate = period.moved(anchorDate, by: offset)
        } label: {
            Image(systemName: systemName)
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.tintPrimary)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(label)
    }

    private var summaryLayout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
    }

    private var summaryCards: some View {
        summaryLayout {
            StatCard(label: period.recordCountLabel, value: "\(periodItems.count)건")
            StatCard(label: "가장 많은 감정", value: topEmotionText, emotion: topEmotion)
        }
        .padding(.horizontal, 16)
    }

    private var topEmotionText: String {
        guard let top = topEmotion else { return "-" }
        return "\(top.displayName) \(Retrospective.count(of: top, in: periodItems))회"
    }

    private func distributionSection(highlighted: Emotion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("감정 분포")
            EmotionBarChart(items: Retrospective.emotionCounts(in: periodItems), highlighted: highlighted)
        }
        .padding(.horizontal, 16)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.textSecondary)
            .padding(.horizontal, 16)
            .padding(.top, 8)
    }
}

private struct StatCard: View {
    let label: String
    let value: String
    var emotion: Emotion? = nil

    @ScaledMetric(relativeTo: .title3) private var auraSize = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(Color.textSecondary)
            HStack(spacing: 8) {
                if let emotion {
                    EmotionAuraView(emotion: emotion, size: auraSize)
                }
                Text(value)
            }
            .font(.title3.bold())
            .foregroundStyle(Color.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: Retrospective.self, inMemory: true)
}
