import SwiftUI

// 글씨를 아주 크게(접근성 크기) 설정하면 7칸 달력에 글자가 들어가지 않아서
// 달력 대신 보여주는 날짜별 목록 (최신순)
struct DayListView: View {
    let items: [Retrospective]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                NavigationLink {
                    RetrospectiveDetailView(retrospective: item)
                } label: {
                    DayRow(item: item)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct DayRow: View {
    let item: Retrospective

    var body: some View {
        HStack(spacing: 16) {
            EmotionAuraView(emotion: item.emotion, size: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(dateText)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                Text(item.emotion.displayName)
                    .font(.callout)
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 24))
        .contentShape(RoundedRectangle(cornerRadius: 24))
    }

    // 예: 11월 16일 (월)
    private var dateText: String {
        let day = item.date.formatted(.dateTime.month().day().locale(.korean))
        let weekday = item.date.formatted(.dateTime.weekday(.abbreviated).locale(.korean))
        return "\(day) (\(weekday))"
    }
}

#Preview {
    NavigationStack {
        DayListView(items: [
            Retrospective(date: .now, content: "팀 프로젝트 첫 회의", emotion: .joy),
            Retrospective(date: .now.addingTimeInterval(-86_400), content: "피곤한 하루", emotion: .exhausted)
        ])
    }
    .background(Color.bgApp)
    .dynamicTypeSize(.accessibility1)
}
