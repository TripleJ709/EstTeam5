import SwiftData
import SwiftUI

/// 감정 통계 화면입니다.
///
/// 주간 또는 월간 기간을 선택해 기록 건수, 가장 많은 감정, 감정 분포, 한마디 피드백을 보여줍니다. 주간일 때는 AI 주간 회고 리포트 영역도 표시합니다.
struct StatisticsView: View {
    /// 날짜순으로 정렬해 가져온 전체 회고 목록입니다.
    @Query(sort: \Retrospective.date)
    private var retrospectives: [Retrospective]

    /// 선택한 통계 기간입니다. 기본값은 월간입니다.
    @State private var period: StatisticsPeriod = .month
    /// 기간 계산의 기준이 되는 날짜입니다.
    @State private var anchorDate = Date.now
    /// 주간 AI 분석의 상태와 실행을 관리하는 저장소입니다.
    @State private var weeklyAnalysis = WeeklyAnalysisStore()
    /// AI 기능 사용 동의 화면 표시 여부입니다.
    @State private var isShowingAIConsent = false
    /// AI 기능 사용(회고 내용 외부 전송) 동의 여부입니다.
    @AppStorage("hasAgreedToAIDataSharing") private var hasAgreedToAIDataSharing = false

    /// 현재 Dynamic Type 크기입니다.
    @Environment(\.dynamicTypeSize) private var typeSize
    /// 기록이 없을 때 표시하는 안내 문구입니다.
    private static let emptyMessage = "회고를 남기면 감정 흐름과 분포가 채워져요"

    /// 선택한 기간과 기준 날짜에 해당하는 회고 목록입니다.
    private var periodItems: [Retrospective] {
        Retrospective.inPeriod(retrospectives, period, of: anchorDate)
    }

    /// 선택한 기간에서 기록이 가장 많은 감정입니다. 기록이 없으면 `nil`입니다.
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
        .sheet(isPresented: $isShowingAIConsent) {
            AIConsentView(onAgree: {
                startWeeklyAnalysis()
            })
        }
    }

    /// 이번 주 회고로 AI 주간 분석을 시작합니다.
    private func startWeeklyAnalysis() {
        weeklyAnalysis.analyze(WeeklyReflectionInput(retrospectives: retrospectives, weekOf: anchorDate))
    }

    /// 가장 많은 감정의 색 번짐 효과를 얹은 화면 배경입니다.
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

    /// 기록이 있으면 감정 분포, 피드백 카드, 주간일 때 AI 리포트를 보여주고, 없으면 빈 상태를 보여주는 본문입니다.
    @ViewBuilder
    private var content: some View {
        if let top = topEmotion {
            distributionSection(highlighted: top)
            StatisticsFeedbackCard(emotion: top, title: period.feedbackTitle, message: period.feedback(for: top))
                .padding(.horizontal, 16)

            if period == .week {
                WeeklyAIReportSection(state: weeklyAnalysis.state, accentEmotion: top) {
                    if hasAgreedToAIDataSharing {
                        startWeeklyAnalysis()
                    } else {
                        isShowingAIConsent = true
                    }
                }
            }
        } else {
            StatisticsEmptyState(title: period.emptyTitle, message: Self.emptyMessage)
                .padding(.horizontal, 16)
        }
    }

    /// 기간 제목과 이전/다음 이동 버튼을 보여주는 뷰입니다.
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

    /// 기준 날짜를 기간 단위로 이동시키는 버튼을 만듭니다.
    ///
    /// - Parameters:
    ///   - systemName: 버튼에 표시할 SF Symbol 이름입니다.
    ///   - label: 접근성 레이블입니다.
    ///   - offset: 기준 날짜를 이동할 기간 수입니다. 음수이면 과거로 이동합니다.
    /// - Returns: 아이콘 버튼 뷰입니다.
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

    /// Dynamic Type이 접근성 크기이면 세로, 아니면 가로로 배치하는 요약 카드 레이아웃입니다.
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

    /// 가장 많은 감정의 "이름 N회" 문자열입니다. 기록이 없으면 "-"입니다.
    private var topEmotionText: String {
        guard let top = topEmotion else { return "-" }
        return "\(top.displayName) \(Retrospective.count(of: top, in: periodItems))회"
    }

    /// 감정 분포 제목과 막대 그래프를 보여주는 섹션을 만듭니다.
    ///
    /// - Parameter highlighted: 그래프에서 강조할 감정입니다.
    /// - Returns: 섹션 뷰입니다.
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
    /// - Returns: 제목 텍스트 뷰입니다.
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.textSecondary)
            .padding(.horizontal, 16)
            .padding(.top, 8)
    }
}

/// 제목과 값을 보여주는 요약 카드입니다. 감정이 있으면 값 옆에 감정 아우라를 표시합니다.
private struct StatCard: View {
    /// 카드의 제목입니다.
    let label: String
    /// 카드에 표시할 값입니다.
    let value: String
    /// 값 옆에 아우라를 표시할 감정입니다. 기본값은 `nil`입니다.
    var emotion: Emotion? = nil

    /// 감정 아우라 이미지의 크기입니다. `.title3` 글꼴 크기에 맞춰 조정됩니다.
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
