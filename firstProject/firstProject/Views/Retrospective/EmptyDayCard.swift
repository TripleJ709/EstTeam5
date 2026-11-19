import SwiftUI

/// 선택한 날짜에 회고가 없을 때 보여 주는 안내 카드입니다.
struct EmptyDayCard: View {
    /// 카드에 들어갈 문구입니다.
    struct Content {
        let title: String
        let message: String
        let buttonTitle: String?
    }

    /// 카드에 보여 줄 문구입니다.
    let content: Content
    /// 회고 쓰기 버튼을 눌렀을 때 실행할 동작입니다.
    var onWrite: () -> Void = {}

    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .body) private var iconSize = 34

    private var layout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
    }

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
