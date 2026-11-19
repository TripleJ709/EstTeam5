import SwiftData
import SwiftUI

/// 월간 달력과 선택한 날짜의 회고 미리보기를 보여주는 회고 목록 화면입니다.
///
/// 달력에서 날짜를 선택하면 해당 날짜의 회고 목록 또는 빈 날짜 카드를 표시합니다. 툴바에서 테마를 바꾸거나 새 회고를 작성할 수 있습니다.
struct RetrospectiveListView: View {
    /// 저장된 모든 회고를 날짜 내림차순으로 가져옵니다.
    @Query(sort: \Retrospective.date, order: .reverse)
    private var retrospectives: [Retrospective]

    /// 달력에 표시 중인 달입니다.
    @State private var displayedMonth = Date.now
    /// 달력에서 선택한 날짜입니다.
    @State private var selectedDate = Date.now
    /// 회고 작성 시트를 띄우기 위한 요청입니다. `nil`이면 시트를 표시하지 않습니다.
    @State private var writeRequest: WriteRequest?
    /// 테마 선택 알림의 표시 여부입니다.
    @State private var isShowingThemeAlert = false
    /// 사용자가 선택한 앱 테마입니다. `appTheme` 키로 저장됩니다.
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    /// 현재 캘린더입니다.
    private var calendar: Calendar { .current }
    /// 현재 시각입니다.
    private var today: Date { .now }

    /// 작성 시트를 띄우기 위한 요청 정보입니다.
    private struct WriteRequest: Identifiable {
        /// 시트 항목을 구분하는 고유 식별자입니다.
        let id = UUID()
        /// 작성할 회고의 날짜입니다.
        let date: Date
    }

    /// 화면 구성
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(monthSummary)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.top, -6)

                    monthNavigation
                    CalendarView(month: displayedMonth, retrospectives: retrospectives, selectedDate: $selectedDate)
                        .padding(.horizontal, 16)
                    legend
                    selectedDayPreview
                }
                .padding(.bottom, 24)
            }
            .background(Color.bgApp.ignoresSafeArea())
            .navigationTitle("회고")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingThemeAlert = true
                    } label: {
                        Image(systemName: "gearshape")
                            .accessibilityLabel("테마 설정")
                    }
                    .tint(Color.tintPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        writeRequest = WriteRequest(date: today)
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.tintOnPrimary)
                            .accessibilityLabel("회고 작성")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.tintPrimary)
                }
            }
            .alert("테마", isPresented: $isShowingThemeAlert) {
                ForEach(AppTheme.allCases) { theme in
                    Button(theme.title) {
                        appTheme = theme
                    }
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("현재 설정: \(appTheme.title)")
            }
            .sheet(item: $writeRequest) { request in
                NavigationStack {
                    RetrospectiveWriteView(date: request.date)
                }
            }
        }
    }

    /// 표시 중인 달과 이전 달, 다음 달 이동 버튼을 보여주는 영역입니다.
    private var monthNavigation: some View {
        HStack(spacing: 0) {
            Text(displayedMonth.formatted(.dateTime.year().month(.wide).locale(.korean)))
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            monthButton(systemName: "chevron.left", label: "이전 달", offset: -1)
            monthButton(systemName: "chevron.right", label: "다음 달", offset: 1)
        }
        .padding(.top, 12)
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    /// 달 이동 버튼 하나를 만듭니다.
    ///
    /// - Parameters:
    ///   - systemName: 버튼에 표시할 SF Symbol 이름입니다.
    ///   - label: 접근성 레이블입니다.
    ///   - offset: 이동할 달 수입니다. 음수이면 이전 달로 이동합니다.
    /// - Returns: 달 이동 버튼 뷰입니다.
    private func monthButton(systemName: String, label: String, offset: Int) -> some View {
        Button {
            moveMonth(by: offset)
        } label: {
            Image(systemName: systemName)
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.tintPrimary)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(label)
    }

    /// 감정별 색상 범례를 보여주는 영역입니다. 공간에 맞춰 한 줄, 3열, 2열 배치 중 하나를 사용합니다.
    private var legend: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                ForEach(Emotion.allCases) { legendItem($0) }
            }

            legendGrid(columns: 3)
            legendGrid(columns: 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.top, 1)
        .accessibilityHidden(true)
    }

    /// 감정 범례를 지정한 열 수의 격자로 배치합니다.
    ///
    /// - Parameter columns: 한 행에 배치할 감정 항목의 수입니다.
    /// - Returns: 범례 격자 뷰입니다.
    private func legendGrid(columns: Int) -> some View {
        var rows: [[Emotion]] = []
        var currentRow: [Emotion] = []
        for emotion in Emotion.allCases {
            currentRow.append(emotion)
            if currentRow.count == columns {
                rows.append(currentRow)
                currentRow = []
            }
        }
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        return Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 6) {
            ForEach(rows.indices, id: \.self) { index in
                GridRow {
                    ForEach(rows[index]) { legendItem($0) }
                }
            }
        }
    }

    /// 감정 하나의 범례 항목(아우라와 이름)을 만듭니다.
    ///
    /// - Parameter emotion: 표시할 감정입니다.
    /// - Returns: 범례 항목 뷰입니다.
    private func legendItem(_ emotion: Emotion) -> some View {
        HStack(spacing: 4) {
            EmotionAuraView(emotion: emotion, size: 10, showsFace: false)
            Text(emotion.displayName)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
                .fixedSize()
        }
    }

    /// 선택한 날짜의 헤더와 회고 카드 목록 또는 빈 날짜 카드를 보여주는 영역입니다.
    private var selectedDayPreview: some View {
        let items = selectedDayItems
        return VStack(alignment: .leading, spacing: 0) {
            Text(previewHeader(count: items.count))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.textSecondary)
                .frame(minHeight: 42)
                .padding(.horizontal, 32)

            if items.isEmpty {
                EmptyDayCard(content: emptyContent) {
                    writeRequest = WriteRequest(date: selectedDate)
                }
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(items) { item in
                        NavigationLink {
                            RetrospectiveDetailView(retrospective: item)
                        } label: {
                            RetroPreviewCard(
                                emotion: item.emotion,
                                title: items.count > 1 ? "\(item.emotion.displayName) · \(timeText(item.date))" : item.emotion.displayName,
                                content: item.content
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 1)
    }

    /// 선택한 날짜의 회고를 생성 시각 내림차순으로 정렬한 목록입니다.
    private var selectedDayItems: [Retrospective] {
        retrospectives
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// 선택한 날짜가 오늘인지 여부입니다.
    private var isSelectedToday: Bool { calendar.isDate(selectedDate, inSameDayAs: today) }

    /// 선택한 날짜가 오늘 이후인지 여부입니다.
    private var isSelectedFuture: Bool {
        calendar.startOfDay(for: selectedDate) > calendar.startOfDay(for: today)
    }

    /// 선택한 날짜의 미리보기 헤더 문구를 만듭니다.
    ///
    /// "월 일 요일" 형식이며, 오늘이고 회고가 없으면 앞에 "오늘 · "을, 회고가 2개 이상이면 뒤에 " · N개"를 붙입니다.
    ///
    /// - Parameter count: 선택한 날짜의 회고 수입니다.
    /// - Returns: 헤더 문자열입니다.
    private func previewHeader(count: Int) -> String {
        var text = selectedDate.formatted(.dateTime.month().day().weekday(.wide).locale(.korean))
        if isSelectedToday && count == 0 { text = "오늘 · " + text }
        if count > 1 { text += " · \(count)개" }
        return text
    }

    /// 선택한 날짜의 상태(미래, 오늘, 과거)와 전체 회고 유무에 따라 빈 날짜 카드에 표시할 내용을 결정합니다.
    private var emptyContent: EmptyDayCard.Content {
        if isSelectedFuture {
            return .init(title: "아직 오지 않은 날이에요", message: "그날이 되면 회고를 남길 수 있어요", buttonTitle: nil)
        }
        if isSelectedToday {
            if retrospectives.isEmpty {
                return .init(title: "첫 회고를 남겨 보세요", message: "감정을 고르면 달력에 색이 채워져요", buttonTitle: "첫 회고 쓰기")
            }
            return .init(title: "오늘 하루는 어땠나요?", message: "짧게 적고 감정을 골라요", buttonTitle: "회고 쓰기")
        }
        return .init(title: "이날은 기록이 없어요", message: "지난 날도 기록할 수 있어요", buttonTitle: "회고 쓰기")
    }

    /// 날짜를 "시:분" 형태의 한국어 문자열로 변환합니다.
    ///
    /// - Parameter date: 변환할 날짜입니다.
    /// - Returns: 시각 문자열입니다.
    private func timeText(_ date: Date) -> String {
        date.formatted(.dateTime.hour().minute().locale(.korean))
    }

    /// 표시 중인 달의 회고 요약 문구입니다. `Retrospective.monthSummary(of:month:calendar:)`의 결과를 사용합니다.
    private var monthSummary: String {
        Retrospective.monthSummary(of: retrospectives, month: displayedMonth)
    }

    /// 표시 중인 달을 지정한 개월 수만큼 이동하고 선택 날짜를 갱신합니다.
    ///
    /// 이동한 달이 현재 달이면 오늘을, 아니면 그 달의 첫날을 선택합니다. 달 계산에 실패하면 아무 작업도 하지 않습니다.
    ///
    /// - Parameter value: 이동할 개월 수입니다. 음수이면 이전 달로 이동합니다.
    private func moveMonth(by value: Int) {
        guard let moved = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = moved
        if let start = calendar.dateInterval(of: .month, for: moved)?.start {
            selectedDate = calendar.isDate(moved, equalTo: today, toGranularity: .month) ? today : start
        }
    }
}

/// 선택한 날짜의 회고 한 건을 요약해서 보여주는 카드입니다.
private struct RetroPreviewCard: View {
    /// 회고의 감정입니다.
    let emotion: Emotion
    /// 카드에 표시할 제목입니다.
    let title: String
    /// 카드에 표시할 회고 본문입니다. 한 줄까지만 보여줍니다.
    let content: String

    /// 화면 구성
    var body: some View {
        HStack(spacing: 12) {
            EmotionAuraView(emotion: emotion, size: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                Text(content)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            ZStack(alignment: .leading) {
                Color.bgCard
                Ellipse()
                    .fill(RadialGradient(colors: [emotion.auraStart, emotion.auraEnd],
                                         center: .center, startRadius: 0, endRadius: 36))
                    .frame(width: 72, height: 68)
                    .blur(radius: 18)
                    .opacity(0.3)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }
}

#Preview {
    RetrospectiveListView()
        .modelContainer(for: Retrospective.self, inMemory: true)
}
