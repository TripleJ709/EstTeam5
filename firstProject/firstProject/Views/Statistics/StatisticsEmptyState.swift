import SwiftUI

struct StatisticsEmptyState: View {
    let title: String
    let message: String

    private enum Metric {
        static let iconLineWidth: CGFloat = 1.5
        static let iconDash: [CGFloat] = [4, 4]
        static let spacing: CGFloat = 8
        static let titleTopPadding: CGFloat = 8
        static let top: CGFloat = 48
        static let bottom: CGFloat = 40
        static let horizontal: CGFloat = 24
    }

    @ScaledMetric(relativeTo: .headline) private var iconSize = 56

    var body: some View {
        VStack(spacing: Metric.spacing) {
            Circle()
                .strokeBorder(
                    Color.borderDashed,
                    style: StrokeStyle(lineWidth: Metric.iconLineWidth, dash: Metric.iconDash)
                )
                .frame(width: iconSize, height: iconSize)
                .accessibilityHidden(true)

            Text(title)
                .font(.headline.weight(.medium))
                .foregroundStyle(Color.textPrimary)
                .padding(.top, Metric.titleTopPadding)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, Metric.top)
        .padding(.bottom, Metric.bottom)
        .padding(.horizontal, Metric.horizontal)
        .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 28))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatisticsEmptyState(title: "이 달에는 기록이 없어요", message: "회고를 남기면 감정 흐름과 분포가 채워져요")
        .padding(16)
        .background(Color.bgApp)
}
