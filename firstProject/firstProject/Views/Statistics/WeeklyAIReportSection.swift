import SwiftUI

struct WeeklyAIReportSection: View {
    let state: WeeklyAnalysisState
    let accentEmotion: Emotion
    let onAnalyze: () -> Void

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

    private var sectionHeader: some View {
        HStack {
            Text("AI 주간 회고 리포트")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(FeeloColor.textSecondary)

            Spacer()

            if state.isLoaded {
                Button(action: onAnalyze) {
                    Label("다시 분석", systemImage: "arrow.clockwise")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(FeeloColor.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func promptCard(isLoading: Bool, errorMessage: String?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(FeeloColor.tint)

                VStack(alignment: .leading, spacing: 2) {
                    Text("6가지 사고 모델로 이번 주 돌아보기")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(FeeloColor.textPrimary)
                    Text("작성한 회고들을 모아 일어난 일, 마음의 흐름, 좋았던 순간, 마음 쓰인 일, 작은 힌트, 이번 주 한줄로 정리해 드려요.")
                        .font(.footnote)
                        .foregroundStyle(FeeloColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(FeeloColor.destructive)
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
        .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.summary))
    }

    private func reportCard(_ analysis: WeeklyReflectionAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(analysis.thinkingSteps) { step in
                ThinkingStepRow(step: step, accentEmotion: accentEmotion)
            }
        }
        .padding(16)
        .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.summary))
    }
}

private struct ThinkingStepRow: View {
    let step: WeeklyReflectionAnalysis.ThinkingStep
    let accentEmotion: Emotion

    private static let fallbackIcon = "circle"
    private static let icons = [
        "facts": "doc.text",
        "emotionalFlow": "waveform.path.ecg",
        "positives": "sun.max",
        "regrets": "cloud.rain",
        "solutions": "lightbulb",
        "summary": "quote.opening"
    ]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: Self.icons[step.id] ?? Self.fallbackIcon)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(FeeloColor.textPrimary)
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
                    .foregroundStyle(FeeloColor.textSecondary)
                Text(step.content)
                    .font(.subheadline)
                    .foregroundStyle(FeeloColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}
