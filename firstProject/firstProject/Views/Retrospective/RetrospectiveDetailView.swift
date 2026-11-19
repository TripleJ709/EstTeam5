import SwiftData
import SwiftUI

/// 저장된 회고 하나의 상세 내용을 보여주는 화면입니다.
///
/// 상단에는 감정 아우라와 날짜, 하단에는 회고 본문을 표시합니다. 툴바 메뉴에서 회고를 편집하거나 삭제할 수 있습니다.
struct RetrospectiveDetailView: View {
    /// 화면에 표시할 회고입니다.
    let retrospective: Retrospective

    /// 회고를 삭제할 때 사용하는 SwiftData 모델 컨텍스트입니다.
    @Environment(\.modelContext) private var modelContext
    /// 현재 화면을 닫는 동작입니다. 회고 삭제 후 호출합니다.
    @Environment(\.dismiss) private var dismiss
    /// 편집 시트(`RetrospectiveWriteView`)의 표시 여부입니다.
    @State private var isEditing = false
    /// 삭제 확인 대화상자의 표시 여부입니다.
    @State private var isConfirmingDelete = false

    /// 화면 구성
    var body: some View {
        ZStack(alignment: .top) {
            Color.bgApp.ignoresSafeArea()

            EmotionWash(emotion: retrospective.emotion)
                .offset(y: -90)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    emotionHeader
                    contentSection
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(navigationTitleText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("회고 편집") { isEditing = true }
                    Button("회고 삭제", role: .destructive) { isConfirmingDelete = true }
                } label: {
                    Image(systemName: "ellipsis")
                        .accessibilityLabel("더보기")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                RetrospectiveWriteView(retrospective: retrospective)
            }
        }
        .confirmationDialog("이 회고를 삭제할까요?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("회고 삭제", role: .destructive) {
                modelContext.delete(retrospective)
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("삭제한 회고는 되돌릴 수 없어요.")
        }
    }

    /// 내비게이션 바에 표시할 "월 일 (요일)" 형태의 한국어 제목입니다.
    private var navigationTitleText: String {
        let day = retrospective.date.formatted(.dateTime.month().day().locale(.korean))
        let weekday = retrospective.date.formatted(.dateTime.weekday(.abbreviated).locale(.korean))
        return "\(day) (\(weekday))"
    }

    /// 감정 아우라, 감정 이름, 회고 날짜와 시각을 보여주는 상단 영역입니다.
    private var emotionHeader: some View {
        VStack(spacing: 8) {
            EmotionAuraView(emotion: retrospective.emotion, size: 72)
            Text(retrospective.emotion.displayName)
                .font(.title2.bold())
                .foregroundStyle(Color.textPrimary)
            Text(retrospective.date.formatted(
                .dateTime.year().month().day().weekday(.wide).hour().minute().locale(.korean)
            ))
            .font(.footnote)
            .foregroundStyle(Color.textSecondary)
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    /// "회고" 제목과 회고 본문 카드를 보여주는 영역입니다.
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("회고")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)
                .padding(.horizontal, 16)

            Text(retrospective.content)
                .font(.body)
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 26))
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    NavigationStack {
        RetrospectiveDetailView(
            retrospective: Retrospective(
                content: "팀 프로젝트 첫 회의에서 각자 역할을 정했다. 처음이라 걱정했는데 생각보다 의견이 잘 맞아서 순조롭게 끝났다.",
                emotion: .joy
            )
        )
    }
    .modelContainer(for: Retrospective.self, inMemory: true)
}
