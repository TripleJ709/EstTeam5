import SwiftUI

/// 선택한 기간에 기록이 없을 때 보여주는 빈 상태 뷰입니다.
struct StatisticsEmptyState: View {
    /// 빈 상태의 제목입니다.
    let title: String
    /// 제목 아래에 표시할 안내 문구입니다.
    let message: String

    /// 레이아웃에 사용하는 상수 모음입니다.
    private enum Metric {
        /// 점선 원의 선 두께입니다.
        static let iconLineWidth: CGFloat = 1.5
        /// 점선 원의 대시 패턴입니다.
        static let iconDash: [CGFloat] = [4, 4]
        /// 요소 사이의 세로 간격입니다.
        static let spacing: CGFloat = 8
        /// 제목 위쪽 추가 여백입니다.
        static let titleTopPadding: CGFloat = 8
        /// 뷰의 위쪽 여백입니다.
        static let top: CGFloat = 48
        /// 뷰의 아래쪽 여백입니다.
        static let bottom: CGFloat = 40
        /// 뷰의 좌우 여백입니다.
        static let horizontal: CGFloat = 24
    }

    /// 점선 원 아이콘의 크기입니다. `.headline` 글꼴 크기에 맞춰 조정됩니다.
    @ScaledMetric(relativeTo: .headline) private var iconSize = 56

    /// 화면 구성
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
