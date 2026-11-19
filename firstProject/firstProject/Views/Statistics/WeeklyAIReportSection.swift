import SwiftUI

/// AI 주간 회고 리포트 섹션 뷰입니다.
///
/// 분석 상태에 따라 분석 시작 카드, 로딩, 오류 메시지가 있는 카드, 결과 리포트 카드 중 하나를 보여줍니다.
struct WeeklyAIReportSection: View {
    /// 주간 분석의 현재 상태입니다.
    let state: WeeklyAnalysisState
    /// 리포트 항목 아이콘 배경 그라디언트에 사용할 강조 감정입니다.
    let accentEmotion: Emotion
    /// 분석 시작 또는 다시 분석 버튼을 눌렀을 때 실행하는 동작입니다.
    let onAnalyze: () -> Void

    /// 화면 구성
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader

            switch state {
            case .idle:
                promptCard(isLoading: false, errorMessage: nil)
            case .loading:
                promptCard(isLoading: true, errorMessage: nil)
            case .failed(let message):
                promptCard(isLoading: false, errorMessage: message)
            case .loaded(let analysis):
                reportCard(analysis)
            }
        }
        .padding(.horizontal, 16)
    }

    /// 섹션 제목과, 분석 결과가 있을 때 나타나는 "다시 분석" 버튼을 보여주는 헤더입니다.
    private var sectionHeader: some View {
        HStack {
            Text("AI 주간 회고 리포트")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)

            Spacer()

            if state.isLoaded {
                Button(action: onAnalyze) {
                    Label("다시 분석", systemImage: "arrow.clockwise")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    /// 분석 시작 안내와 버튼을 보여주는 카드를 만듭니다.
    ///
    /// - Parameters:
    ///   - isLoading: true이면 진행 표시와 안내 문구를 보여주고 버튼을 비활성화합니다.
    ///   - errorMessage: nil이 아니면 카드에 오류 문구로 표시합니다.
    /// - Returns: 카드 뷰를 반환합니다.
    private func promptCard(isLoading: Bool, errorMessage: String?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(Color.tintPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("6가지 사고 모델로 이번 주 돌아보기")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text("작성한 회고들을 모아 일어난 일, 마음의 흐름, 좋았던 순간, 마음 쓰인 일, 작은 힌트, 이번 주 한줄로 정리해 드려요.")
                        .font(.footnote)
                        .foregroundStyle(Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Color.statusDestructive)
            }

            Button(action: onAnalyze) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "wand.and.stars")
                    }
                    Text(isLoading ? "이번 주 회고를 분석하는 중..." : "AI 주간 분석 시작하기")
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)
        }
        .padding(16)
        .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 24))
    }

    /// 분석 결과의 사고 단계 목록을 보여주는 리포트 카드를 만듭니다.
    ///
    /// - Parameter analysis: 표시할 주간 분석 결과입니다.
    /// - Returns: 카드 뷰를 반환합니다.
    private func reportCard(_ analysis: WeeklyReflectionAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(analysis.thinkingSteps) { step in
                ThinkingStepRow(step: step, accentEmotion: accentEmotion)
            }
        }
        .padding(16)
        .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 24))
    }
}

/// 주간 분석 결과의 사고 단계 하나(아이콘, 제목, 내용)를 보여주는 행 뷰입니다.
private struct ThinkingStepRow: View {
    /// 표시할 사고 단계입니다.
    let step: WeeklyReflectionAnalysis.ThinkingStep
    /// 아이콘 배경 그라디언트에 사용할 강조 감정입니다.
    let accentEmotion: Emotion

    /// 단계 ID에 맞는 아이콘이 없을 때 쓰는 SF Symbol 이름입니다.
    private static let fallbackIcon = "circle"
    /// 단계 ID별 SF Symbol 아이콘 이름입니다.
    private static let icons = [
        "facts": "doc.text",
        "emotionalFlow": "waveform.path.ecg",
        "positives": "sun.max",
        "regrets": "cloud.rain",
        "solutions": "lightbulb",
        "summary": "quote.opening"
    ]

    /// 화면 구성
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: Self.icons[step.id] ?? Self.fallbackIcon)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textPrimary)
                .frame(width: 28, height: 28)
                .background(
                    LinearGradient(
                        colors: [accentEmotion.auraStart.opacity(0.35), accentEmotion.auraEnd.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Circle()
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(step.title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
                Text(step.content)
                    .font(.subheadline)
                    .foregroundStyle(Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}
