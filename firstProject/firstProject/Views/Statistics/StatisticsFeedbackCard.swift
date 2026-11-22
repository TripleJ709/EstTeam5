import SwiftUI

/// 감정에 대한 한마디 피드백을 보여주는 카드 뷰입니다.
struct StatisticsFeedbackCard: View {
    /// 카드에 표시할 감정입니다.
    let emotion: Emotion
    /// 피드백의 제목입니다.
    let title: String
    /// 피드백 본문입니다.
    let message: String

    /// 레이아웃에 사용하는 상수 모음입니다.
    private enum Metric {
        /// 아우라와 텍스트 사이의 간격입니다.
        static let spacing: CGFloat = 12
        /// 제목과 본문 사이의 간격입니다.
        static let textSpacing: CGFloat = 2
        /// 카드의 안쪽 여백입니다.
        static let padding: CGFloat = 16
    }

    /// 현재 Dynamic Type 크기입니다.
    @Environment(\.dynamicTypeSize) private var typeSize
    /// 감정 아우라 이미지의 크기입니다. `.subheadline` 글꼴 크기에 맞춰 조정됩니다.
    @ScaledMetric(relativeTo: .subheadline) private var auraSize = 40

    /// Dynamic Type이 접근성 크기이면 세로, 아니면 가로로 배치하는 레이아웃입니다.
    private var layout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Metric.spacing))
            : AnyLayout(HStackLayout(spacing: Metric.spacing))
    }

    /// 화면 구성
    var body: some View {
        layout {
            EmotionAuraView(emotion: emotion, size: auraSize)

            VStack(alignment: .leading, spacing: Metric.textSpacing) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(Color.textSecondary)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Metric.padding)
        .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: .combine)
    }
}

#Preview("주간") {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(Emotion.allCases) { emotion in
                StatisticsFeedbackCard(emotion: emotion, title: "이번 주의 한마디", message: emotion.weeklyFeedback)
            }
        }
        .padding(16)
    }
    .background(Color.bgApp)
}

#Preview("월간") {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(Emotion.allCases) { emotion in
                StatisticsFeedbackCard(emotion: emotion, title: "이번 달의 한마디", message: emotion.monthlyFeedback)
            }
        }
        .padding(16)
    }
    .background(Color.bgApp)
}
