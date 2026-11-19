import SwiftUI

/// 기록이 없는 날에 안내 문구와 작성 버튼을 보여주는 카드 뷰입니다.
struct EmptyDayCard: View {
    /// 카드에 표시할 내용입니다.
    struct Content {
        /// 제목입니다.
        let title: String
        /// 안내 메시지입니다.
        let message: String
        /// 버튼 제목입니다. `nil`이면 버튼을 표시하지 않습니다.
        let buttonTitle: String?
    }

    /// 카드에 표시할 내용입니다.
    let content: Content
    /// 버튼을 눌렀을 때 호출되는 동작입니다. 기본값은 아무 동작도 하지 않는 클로저입니다.
    var onWrite: () -> Void = {}

    /// 현재 Dynamic Type 크기 설정입니다.
    @Environment(\.dynamicTypeSize) private var typeSize
    /// 점선 원 아이콘의 크기이며 글자 크기 설정에 따라 조정됩니다.
    @ScaledMetric(relativeTo: .body) private var iconSize = 34

    /// 접근성 크기에서는 세로, 그 외에는 가로로 배치하는 레이아웃입니다.
    private var layout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
    }

    /// 화면 구성
    var body: some View {
        layout {
            Circle()
                .strokeBorder(Color.borderDashed, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                .frame(width: iconSize, height: iconSize)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(content.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                Text(content.message)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)

            if let buttonTitle = content.buttonTitle {
                Button(action: onWrite) {
                    Text(buttonTitle)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.tintOnPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(minHeight: 36)
                        .background(Color.tintPrimary, in: Capsule())
                }
                .fixedSize()
            }
        }
        .padding(16)
        .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 28))
    }
}

#Preview {
    VStack(spacing: 8) {
        EmptyDayCard(content: .init(title: "이날은 기록이 없어요", message: "지난 날도 기록할 수 있어요", buttonTitle: "회고 쓰기"))
        EmptyDayCard(content: .init(title: "아직 오지 않은 날이에요", message: "그날이 되면 회고를 남길 수 있어요", buttonTitle: nil))
    }
    .padding(16)
    .background(Color.bgApp)
}
