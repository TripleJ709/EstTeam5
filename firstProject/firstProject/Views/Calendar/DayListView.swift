import SwiftUI

// 글씨를 아주 크게(접근성 크기) 설정하면 7칸 달력에 글자가 들어가지 않아서
// 달력 대신 보여주는 날짜별 목록 (최신순)
/// 날짜별 회고 목록을 카드 형태로 보여주는 뷰입니다.
///
/// 각 카드를 누르면 해당 회고의 상세 화면(`RetrospectiveDetailView`)으로 이동합니다.
struct DayListView: View {
    /// 목록에 표시할 회고입니다.
    let items: [Retrospective]

    /// 화면 구성: 회고마다 상세 화면으로 이동하는 `DayRow`를 세로로 나열합니다.
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

/// 회고 하나를 감정 오로라, 날짜, 감정 이름으로 보여주는 카드 행입니다.
private struct DayRow: View {
    /// 표시할 회고입니다.
    let item: Retrospective

    /// 화면 구성: 감정 오로라와 날짜·감정 이름을 가로로 배치한 카드입니다.
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
    /// "11월 16일 (월)" 형태의 날짜 문구입니다.
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
