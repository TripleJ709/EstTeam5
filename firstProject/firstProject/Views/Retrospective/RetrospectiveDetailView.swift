import SwiftData
import SwiftUI

struct RetrospectiveDetailView: View {
    let retrospective: Retrospective

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var isConfirmingDelete = false

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
        .alert("이 회고를 삭제할까요?", isPresented: $isConfirmingDelete) {
            Button("삭제", role: .destructive) {
                modelContext.delete(retrospective)
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("삭제한 회고는 되돌릴 수 없어요.")
        }
    }

    private var navigationTitleText: String {
        let day = retrospective.date.formatted(.dateTime.month().day().locale(.korean))
        let weekday = retrospective.date.formatted(.dateTime.weekday(.abbreviated).locale(.korean))
        return "\(day) (\(weekday))"
    }

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
