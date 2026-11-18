import SwiftData
import SwiftUI

struct StatisticsView: View {
    @Query(sort: \Retrospective.date)
    private var retrospectives: [Retrospective]

    @State private var period: StatisticsPeriod = .month
    @State private var anchorDate = Date.now

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
        .tint(FeeloColor.tint)
    }

    private var screenBackground: some View {
        ZStack(alignment: .top) {
            FeeloColor.bgApp

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
        } else {
            StatisticsEmptyState(title: period.emptyTitle, message: Self.emptyMessage)
                .padding(.horizontal, 16)
        }
    }

    private var periodNavigation: some View {
        HStack(spacing: 0) {
            Text(period.title(of: anchorDate))
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
            anchorDate = period.moved(anchorDate, by: offset)
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
                Text("\(periodItems.count)건")
            }
            StatCard(label: "가장 많은 감정") {
                if let top = topEmotion {
                    HStack(spacing: 8) {
                        EmotionAuraView(emotion: top, size: 20)
                        Text("\(top.displayName) \(Retrospective.count(of: top, in: periodItems))회")
                    }
                } else {
                    Text("-")
                }
            }
        }
        .padding(.horizontal, 16)
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
