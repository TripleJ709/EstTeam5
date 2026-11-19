import SwiftUI

/// 감정별 기록 횟수를 보여 주는 막대 그래프입니다.
///
/// 7가지 감정을 항상 보여 주고, 기록이 없는 감정은 흐리게 표시합니다.
/// 막대 높이는 가장 많은 횟수를 기준으로 한 비율입니다.
struct EmotionBarChart: View {
    /// 그래프에 보여 줄 감정별 횟수입니다.
    let items: [EmotionCount]
    /// 굵게 강조할 감정입니다. 보통 가장 많이 기록한 감정입니다.
    let highlighted: Emotion?

    private enum Metric {
        static let maxBarHeight: CGFloat = 100
        static let minBarHeight: CGFloat = 4
        static let barWidth: CGFloat = 28
        static let columnSpacing: CGFloat = 5
        static let labelSpacing: CGFloat = 4
        static let padding: CGFloat = 16
        static let barCorner: CGFloat = 8
        static let emptyBarCorner: CGFloat = 4
        static let emptyOpacity = 0.4
    }

    private var maxCount: Int {
        var result = 1
        for item in items {
            if item.count > result {
                result = item.count
            }
        }
        return result
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: Metric.columnSpacing) {
            ForEach(items) { item in
                column(emotion: item.emotion, count: item.count)
            }
        }
        .padding(Metric.padding)
        .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 28))
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("감정 분포")
        .accessibilityValue(accessibilityValue)
    }

    private func column(emotion: Emotion, count: Int) -> some View {
        let isHighlighted = emotion == highlighted
        let isEmpty = count == 0

        return VStack(spacing: Metric.labelSpacing) {
            Text("\(count)")
                .font(.footnote.weight(isHighlighted ? .medium : .regular))
                .foregroundStyle(isEmpty ? Color.textSecondary : Color.textPrimary)

            bar(emotion: emotion, count: count)

            Text(emotion.displayName)
                .font(.footnote.weight(isHighlighted ? .medium : .regular))
                .foregroundStyle(isHighlighted ? Color.textPrimary : Color.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .opacity(isEmpty ? Metric.emptyOpacity : 1)
    }

    private func bar(emotion: Emotion, count: Int) -> some View {
        let corner = count == 0 ? Metric.emptyBarCorner : Metric.barCorner
        return UnevenRoundedRectangle(topLeadingRadius: corner, topTrailingRadius: corner)
            .fill(LinearGradient(colors: [emotion.auraStart, emotion.auraEnd], startPoint: .top, endPoint: .bottom))
            .frame(width: Metric.barWidth, height: barHeight(for: count))
    }

    private func barHeight(for count: Int) -> CGFloat {
        let ratio = CGFloat(count) / CGFloat(maxCount)
        return Metric.minBarHeight + (Metric.maxBarHeight - Metric.minBarHeight) * ratio
    }

    private var accessibilityValue: String {
        let recorded = items.filter { $0.count > 0 }
        guard !recorded.isEmpty else { return "기록 없음" }
        return recorded.map { "\($0.emotion.displayName) \($0.count)회" }.joined(separator: ", ")
    }
}

#Preview {
    EmotionBarChart(
        items: [
            EmotionCount(emotion: .joy, count: 1),
            EmotionCount(emotion: .achievement, count: 2),
            EmotionCount(emotion: .stable, count: 1),
            EmotionCount(emotion: .angry, count: 0),
            EmotionCount(emotion: .fear, count: 0),
            EmotionCount(emotion: .sad, count: 1),
            EmotionCount(emotion: .exhausted, count: 0)
        ],
        highlighted: .achievement
    )
    .padding(16)
    .background(Color.bgApp)
}
