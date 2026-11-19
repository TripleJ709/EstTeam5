import SwiftUI

/// 감정별 기록 횟수를 세로 막대로 보여주는 차트 뷰입니다.
///
/// 막대 높이는 가장 큰 횟수를 기준으로 비율 계산하며, 강조된 감정은 글자 굵기가 달라집니다.
struct EmotionBarChart: View {
    /// 감정별 기록 횟수 목록입니다. 목록 순서대로 막대가 배치됩니다.
    let items: [EmotionCount]
    /// 강조해서 표시할 감정입니다. 해당 감정 열의 글자가 굵게, 라벨이 기본 글자색으로 표시됩니다.
    let highlighted: Emotion?

    /// 차트 레이아웃에 쓰는 크기와 간격 상수 모음입니다.
    private enum Metric {
        /// 막대의 최대 높이입니다.
        static let maxBarHeight: CGFloat = 100
        /// 막대의 최소 높이입니다.
        static let minBarHeight: CGFloat = 4
        /// 막대의 너비입니다.
        static let barWidth: CGFloat = 28
        /// 막대 열 사이의 간격입니다.
        static let columnSpacing: CGFloat = 5
        /// 열 안에서 횟수, 막대, 라벨 사이의 간격입니다.
        static let labelSpacing: CGFloat = 4
        /// 차트 바깥 여백입니다.
        static let padding: CGFloat = 16
        /// 횟수가 1 이상인 막대의 위쪽 모서리 반지름입니다.
        static let barCorner: CGFloat = 8
        /// 횟수가 0인 막대의 위쪽 모서리 반지름입니다.
        static let emptyBarCorner: CGFloat = 4
        /// 횟수가 0인 열에 적용하는 불투명도입니다.
        static let emptyOpacity = 0.4
    }

    /// 항목 중 가장 큰 횟수를 반환합니다. 최소값은 1이라 0으로 나누지 않습니다.
    private var maxCount: Int {
        var result = 1
        for item in items {
            if item.count > result {
                result = item.count
            }
        }
        return result
    }

    /// 화면 구성
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

    /// 감정 하나에 대한 열(횟수, 막대, 감정 이름)을 구성합니다.
    ///
    /// - Parameters:
    ///   - emotion: 표시할 감정입니다.
    ///   - count: 해당 감정의 기록 횟수입니다.
    /// - Returns: 열 뷰를 반환합니다.
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

    /// 감정의 색상 그라디언트로 채운 막대를 만듭니다.
    ///
    /// - Parameters:
    ///   - emotion: 막대 색상에 사용할 감정입니다.
    ///   - count: 기록 횟수입니다. 0이면 모서리 반지름이 더 작습니다.
    /// - Returns: 막대 뷰를 반환합니다.
    private func bar(emotion: Emotion, count: Int) -> some View {
        let corner = count == 0 ? Metric.emptyBarCorner : Metric.barCorner
        return UnevenRoundedRectangle(topLeadingRadius: corner, topTrailingRadius: corner)
            .fill(LinearGradient(colors: [emotion.auraStart, emotion.auraEnd], startPoint: .top, endPoint: .bottom))
            .frame(width: Metric.barWidth, height: barHeight(for: count))
    }

    /// 횟수에 비례한 막대 높이를 계산합니다.
    ///
    /// 최소 높이에서 최대 높이 사이를 가장 큰 횟수 대비 비율로 보간합니다.
    ///
    /// - Parameter count: 기록 횟수입니다.
    /// - Returns: 막대 높이입니다.
    private func barHeight(for count: Int) -> CGFloat {
        let ratio = CGFloat(count) / CGFloat(maxCount)
        return Metric.minBarHeight + (Metric.maxBarHeight - Metric.minBarHeight) * ratio
    }

    /// 접근성용 값 문자열입니다. 기록된 감정을 "이름 N회" 형태로 쉼표로 잇고, 기록이 없으면 "기록 없음"입니다.
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
