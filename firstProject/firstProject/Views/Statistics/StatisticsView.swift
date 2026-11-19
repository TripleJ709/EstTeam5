import SwiftData
import SwiftUI

/// 기간별 감정 통계를 보여주는 화면입니다.
///
/// 주간 또는 월간 기간을 선택해 기록 건수, 가장 많은 감정, 감정 분포, 피드백을 보여줍니다. 주간에서는 AI 주간 리포트 섹션도 표시합니다.
struct StatisticsView: View {
    /// 저장된 회고 전체를 날짜순으로 가져옵니다.
    @Query(sort: \Retrospective.date)
    private var retrospectives: [Retrospective]

    /// 선택된 통계 기간(주간/월간)입니다. 기본값은 월간입니다.
    @State private var period: StatisticsPeriod = .month
    /// 통계 대상 기간을 정하는 기준 날짜입니다.
    @State private var anchorDate = Date.now
    /// 주간 AI 분석의 상태와 실행을 관리하는 저장소입니다.
    @State private var weeklyAnalysis = WeeklyAnalysisStore()

    /// 현재 Dynamic Type(글자 크기 설정) 크기입니다.
    @Environment(\.dynamicTypeSize) private var typeSize
    /// 기록이 없을 때 빈 상태에 표시하는 안내 문구입니다.
    private static let emptyMessage = "회고를 남기면 감정 흐름과 분포가 채워져요"

    /// 기준 날짜가 속한 기간의 회고 목록입니다.
    private var periodItems: [Retrospective] {
        Retrospective.inPeriod(retrospectives, period, of: anchorDate)
    }

    /// 선택한 기간에서 가장 많이 기록된 감정입니다. 기록이 없으면 nil입니다.
    private var topEmotion: Emotion? {
        Retrospective.topEmotion(in: periodItems)
    }

    /// 화면 구성
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

    /// 최다 감정이 있으면 그 감정의 색 번짐을 깔아주는 화면 배경입니다.
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

    /// 기록이 있으면 분포, 피드백 카드, 주간 AI 리포트(주간일 때)를, 없으면 빈 상태를 보여주는 본문입니다.
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

    /// 기간 제목과 이전/다음 이동 버튼을 보여주는 기간 이동 영역입니다.
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

    /// 기준 날짜를 한 기간 단위로 옮기는 버튼을 만듭니다.
    ///
    /// - Parameters:
    ///   - systemName: 버튼 아이콘의 SF Symbol 이름입니다.
    ///   - label: 접근성 라벨입니다.
    ///   - offset: 이동할 기간 수입니다. 음수면 과거로 이동합니다.
    /// - Returns: 버튼 뷰를 반환합니다.
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

    /// 글자 크기가 접근성 크기이면 세로, 아니면 가로로 배치하는 요약 카드 레이아웃입니다.
    private var summaryLayout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
    }

    /// 기록 건수와 가장 많은 감정을 보여주는 요약 카드 영역입니다.
    private var summaryCards: some View {
        summaryLayout {
            StatCard(label: period.recordCountLabel, value: "\(periodItems.count)건")
            StatCard(label: "가장 많은 감정", value: topEmotionText, emotion: topEmotion)
        }
        .padding(.horizontal, 16)
    }

    /// 가장 많은 감정을 "이름 N회" 형태로 만든 문구입니다. 기록이 없으면 "-"입니다.
    private var topEmotionText: String {
        guard let top = topEmotion else { return "-" }
        return "\(top.displayName) \(Retrospective.count(of: top, in: periodItems))회"
    }

    /// 감정 분포 제목과 막대 차트를 보여주는 섹션을 만듭니다.
    ///
    /// - Parameter highlighted: 차트에서 강조할 감정입니다.
    /// - Returns: 섹션 뷰를 반환합니다.
    private func distributionSection(highlighted: Emotion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("감정 분포")
            EmotionBarChart(items: Retrospective.emotionCounts(in: periodItems), highlighted: highlighted)
        }
        .padding(.horizontal, 16)
    }

    /// 섹션 제목 텍스트를 만듭니다.
    ///
    /// - Parameter title: 표시할 제목입니다.
    /// - Returns: 제목 뷰를 반환합니다.
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.textSecondary)
            .padding(.horizontal, 16)
            .padding(.top, 8)
    }
}

/// 라벨과 값을 보여주는 요약 카드 뷰입니다.
private struct StatCard: View {
    /// 카드 위쪽에 표시하는 라벨입니다.
    let label: String
    /// 카드에 크게 표시하는 값입니다.
    let value: String
    /// 값 옆에 아우라를 함께 표시할 감정입니다. nil이면 아우라를 표시하지 않습니다.
    var emotion: Emotion? = nil

    /// 감정 아우라 이미지의 크기입니다. title3 글꼴 크기에 맞춰 조절됩니다.
    @ScaledMetric(relativeTo: .title3) private var auraSize = 20

    /// 화면 구성
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
