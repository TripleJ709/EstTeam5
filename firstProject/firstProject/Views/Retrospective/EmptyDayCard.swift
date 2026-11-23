import SwiftUI

/// 회고가 없는 날에 안내 문구와 (선택적으로) 작성 버튼을 보여주는 카드입니다.
struct EmptyDayCard: View {
    /// 카드에 표시할 문구 모음입니다.
    struct Content {
        /// 카드의 제목입니다.
        let title: String
        /// 카드의 안내 메시지입니다.
        let message: String
        /// 버튼에 표시할 문구입니다. `nil`이면 버튼을 표시하지 않습니다.
        let buttonTitle: String?
    }

    /// 카드에 표시할 문구 내용입니다.
    let content: Content
    /// 버튼을 눌렀을 때 호출되는 클로저입니다. 기본값은 아무 동작도 하지 않습니다.
    var onWrite: () -> Void = {}

    /// 현재 Dynamic Type 글씨 크기 설정입니다.
    @Environment(\.dynamicTypeSize) private var typeSize
    /// 글씨 크기에 비례해 조절되는 점선 원의 크기입니다. 기본값은 34입니다.
    @ScaledMetric(relativeTo: .body) private var iconSize = 34

    /// 접근성 글씨 크기일 때는 세로 배치(`VStackLayout`), 그렇지 않으면 가로 배치(`HStackLayout`)를 반환합니다.
    private var layout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
    }

    /// 화면 구성: 점선 원, 제목·메시지, 버튼(`buttonTitle`이 있을 때만)을 `layout`에 따라 배치합니다.
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
