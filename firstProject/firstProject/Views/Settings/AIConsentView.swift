import SwiftUI

/// AI 기능을 처음 쓸 때 회고 내용이 어디로 전송되는지 알리고 동의를 받는 화면입니다.
///
/// 동의하면 `hasAgreedToAIDataSharing` 키에 저장하고 `onAgree`를 실행합니다.
/// 동의는 달력 탭 왼쪽 위 메뉴에서 철회할 수 있습니다.
struct AIConsentView: View {
    /// 사용자가 동의했을 때 실행할 동작입니다. 예: AI 감정 추천 시작
    let onAgree: () -> Void

    /// 현재 화면을 닫는 동작입니다.
    @Environment(\.dismiss) private var dismiss
    /// AI 기능 사용(회고 내용 외부 전송) 동의 여부입니다.
    @AppStorage("hasAgreedToAIDataSharing") private var hasAgreedToAIDataSharing = false
    /// 사용자가 만 14세 이상이라고 확인했는지 여부입니다. 확인해야 동의 버튼을 누를 수 있어요.
    @State private var isAgeConfirmed = false

    /// 화면 구성
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("AI 기능을 사용하면 회고 내용이 외부 AI 서비스로 전송돼요. 아래 내용을 확인하고 동의해 주세요.")
                        .font(.body)
                        .foregroundStyle(Color.textPrimary)

                    infoRow(title: "보내는 내용", text: "감정 추천: 작성 중인 회고 본문\n주간 분석: 이번 주 회고 본문, 날짜·요일, 감정, 감정 통계")
                    infoRow(title: "받는 곳", text: "Google Firebase 서버를 거쳐 OpenAI(미국)로 전송돼요.")
                    infoRow(title: "사용 목적", text: "감정 추천과 주간 분석 결과를 만드는 데만 사용해요.")
                    infoRow(title: "보관 기간", text: "Feelo 서버에는 저장하지 않아요. OpenAI는 전송된 내용을 AI 학습에 쓰지 않고, 남용 감시를 위해 최대 30일 보관한 뒤 삭제해요.")
                    infoRow(title: "이용 연령", text: "AI 기능은 만 14세 이상만 사용할 수 있어요.")
                    infoRow(title: "동의하지 않으면", text: "AI 기능만 사용할 수 없어요. 회고 작성, 달력, 통계는 그대로 사용할 수 있어요.\n동의는 달력 탭 왼쪽 위 메뉴에서 언제든 철회할 수 있어요.")

                    if let url = AppLink.privacyPolicy {
                        Link("개인정보처리방침 자세히 보기", destination: url)
                            .font(.subheadline.weight(.medium))
                            .tint(Color.tintPrimary)
                    }
                }
                .padding(16)
            }
            .background(Color.bgApp)
            .safeAreaInset(edge: .bottom) {
                buttons
            }
            .navigationTitle("AI 기능 사용 동의")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// 항목 제목과 설명을 한 묶음으로 보여주는 뷰를 만듭니다.
    ///
    /// - Parameters:
    ///   - title: 항목 제목입니다. 예: "보내는 내용"
    ///   - text: 항목 설명입니다.
    /// - Returns: 제목과 설명을 세로로 쌓은 뷰입니다.
    private func infoRow(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
    }

    /// 만 14세 이상 확인 체크, 동의 버튼, 동의하지 않음 버튼입니다.
    private var buttons: some View {
        VStack(spacing: 8) {
            Button {
                isAgeConfirmed.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isAgeConfirmed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isAgeConfirmed ? Color.tintPrimary : Color.textSecondary)
                    Text("만 14세 이상이에요")
                        .font(.subheadline)
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)

            Button {
                hasAgreedToAIDataSharing = true
                dismiss()
                onAgree()
            } label: {
                Text("동의하고 계속하기")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.tintOnPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.tintPrimary)
            .disabled(!isAgeConfirmed)

            Button("동의하지 않음") {
                dismiss()
            }
            .font(.subheadline)
            .foregroundStyle(Color.textSecondary)
            .padding(.vertical, 8)
        }
        .padding(16)
        .background(Color.bgApp)
    }
}

#Preview {
    AIConsentView(onAgree: {})
}
