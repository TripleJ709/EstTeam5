import SwiftUI

/// 가장 많이 기록한 감정에 맞춘 한마디를 보여 주는 카드입니다.
struct StatisticsFeedbackCard: View {
    /// 카드에 아우라로 보여 줄 감정입니다.
    let emotion: Emotion
    /// 카드 제목입니다. 예: `이번 주의 한마디`
    let title: String
    /// 보여 줄 한마디 문구입니다.
    let message: String

    private enum Metric {
        static let spacing: CGFloat = 12
        static let textSpacing: CGFloat = 2
        static let padding: CGFloat = 16
    }

    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .subheadline) private var auraSize = 40

    private var layout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Metric.spacing))
            : AnyLayout(HStackLayout(spacing: Metric.spacing))
    }

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
