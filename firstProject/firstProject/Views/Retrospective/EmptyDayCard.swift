import SwiftUI

struct EmptyDayCard: View {
    struct Content {
        let title: String
        let message: String
        let buttonTitle: String?
    }

    let content: Content
    var onWrite: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .strokeBorder(FeeloColor.borderDashed, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                .frame(width: 34, height: 34)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(content.title)
                    .font(.system(size: 17, weight: .medium))
                    .tracking(-0.43)
                    .foregroundStyle(FeeloColor.textPrimary)
                Text(content.message)
                    .font(.system(size: 15))
                    .tracking(-0.23)
                    .foregroundStyle(FeeloColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let buttonTitle = content.buttonTitle {
                Button(action: onWrite) {
                    Text(buttonTitle)
                        .font(.system(size: 15, weight: .medium))
                        .tracking(-0.23)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                        .background(FeeloColor.tint, in: Capsule())
                }
                .fixedSize()
            }
        }
        .padding(16)
        .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.calendar))
    }
}

#Preview {
    VStack(spacing: 8) {
        EmptyDayCard(content: .init(title: "이날은 기록이 없어요", message: "지난 날도 기록할 수 있어요", buttonTitle: "회고 쓰기"))
        EmptyDayCard(content: .init(title: "아직 오지 않은 날이에요", message: "그날이 되면 회고를 남길 수 있어요", buttonTitle: nil))
    }
    .padding(16)
    .background(FeeloColor.bgApp)
}
