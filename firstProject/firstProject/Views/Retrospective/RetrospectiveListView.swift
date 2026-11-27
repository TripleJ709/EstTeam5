import SwiftData
import SwiftUI

/// 달력과 선택한 날짜의 회고를 보여주는 회고 목록 화면입니다.
///
/// 월 이동, 달력, 감정 범례, 선택한 날의 회고 미리보기를 제공하고, 툴바에서 테마 변경과 회고 작성을 할 수 있습니다.
struct RetrospectiveListView: View {
    /// 저장된 모든 회고이며 날짜 기준 내림차순으로 정렬됩니다.
    @Query(sort: \Retrospective.date, order: .reverse)
    private var retrospectives: [Retrospective]

    /// 현재 보고 있는 달입니다.
    @State private var displayedMonth = Date.now
    /// 달력에서 선택한 날짜입니다.
    @State private var selectedDate = Date.now
    /// 회고 작성 시트를 띄우기 위한 요청입니다. 값이 있으면 시트가 표시됩니다.
    @State private var writeRequest: WriteRequest?
    /// 사용자가 선택한 앱 테마이며 `appTheme` 키로 저장됩니다.
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    /// AI 기능 사용(회고 내용 외부 전송) 동의 여부입니다.
    @AppStorage("hasAgreedToAIDataSharing") private var hasAgreedToAIDataSharing = false
    /// 현재 Dynamic Type 글자 크기 설정입니다.
    @Environment(\.dynamicTypeSize) private var typeSize

    /// 현재 캘린더입니다.
    private var calendar: Calendar { .current }
    /// 현재 시각입니다.
    private var today: Date { .now }

    /// 회고 작성 시트를 띄우기 위한 요청 정보입니다.
    private struct WriteRequest: Identifiable {
        /// 요청을 구분하는 고유 식별자입니다.
        let id = UUID()
        /// 작성할 회고의 날짜입니다.
        let date: Date
    }

    /// 화면 구성
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    // 아주 큰 글씨에서는 요약 문구를 숨김 (Figma 01-AX)
                    if !typeSize.isAccessibilitySize {
                        Text(monthSummary)
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.top, -6)
                    }

                    monthNavigation
                    if typeSize.isAccessibilitySize {
                        // 아주 큰 글씨: 달력 대신 날짜별 목록, 기록이 없으면 빈 카드
                        if monthItems.isEmpty {
                            selectedDayPreview
                        } else {
                            DayListView(items: monthItems)
                        }
                    } else {
                        CalendarView(month: displayedMonth, retrospectives: retrospectives, selectedDate: $selectedDate)
                            .padding(.horizontal, 16)
                        legend
                        selectedDayPreview
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.bgApp.ignoresSafeArea())
            .navigationTitle("이 달의 감정")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("테마", selection: $appTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.title).tag(theme)
                            }
                        }
                        Divider()
                        if let url = AppLink.privacyPolicy {
                            Link(destination: url) {
                                Label("개인정보처리방침", systemImage: "hand.raised")
                            }
                        }
                        if hasAgreedToAIDataSharing {
                            Button(role: .destructive) {
                                hasAgreedToAIDataSharing = false
                            } label: {
                                Label("AI 기능 동의 철회", systemImage: "hand.raised.slash")
                            }
                        }
                    } label: {
                        Image(systemName: "circle.lefthalf.filled")
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
            .sheet(item: $writeRequest) { request in
                NavigationStack {
                    RetrospectiveWriteView(date: request.date)
                }
            }
        }
    }

    /// 보고 있는 달의 이름과 이전 달, 다음 달 버튼을 보여주는 영역입니다.
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

    /// 달을 이동하는 아이콘 버튼을 만듭니다.
    ///
    /// - Parameters:
    ///   - systemName: 버튼에 표시할 SF Symbol 이름입니다.
    ///   - label: 접근성 레이블입니다.
    ///   - offset: 이동할 달 수입니다. 음수이면 이전 달, 양수이면 다음 달로 이동합니다.
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

    /// 감정별 색상 범례를 보여주는 영역입니다. 공간에 따라 한 줄, 3열, 2열 배치 중 맞는 것을 사용합니다.
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
    /// - Parameter columns: 한 행에 둘 감정 수입니다.
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

    /// 감정 하나의 아우라와 이름으로 범례 항목을 만듭니다.
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

    /// 선택한 날짜의 회고 미리보기를 보여줍니다. 회고가 없으면 빈 날 카드를, 있으면 상세 화면으로 이동하는 카드 목록을 보여줍니다.
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

    /// 선택한 날짜의 회고이며 생성 시각 기준 최신순으로 정렬됩니다.
    private var selectedDayItems: [Retrospective] {
        retrospectives
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    // 보고 있는 달의 회고 (최신순, @Query에서 이미 정렬됨)
    /// 보고 있는 달에 속한 회고입니다.
    private var monthItems: [Retrospective] {
        retrospectives.filter { calendar.isDate($0.date, equalTo: displayedMonth, toGranularity: .month) }
    }

    /// 선택한 날짜가 오늘인지 여부입니다.
    private var isSelectedToday: Bool { calendar.isDate(selectedDate, inSameDayAs: today) }

    /// 선택한 날짜가 오늘 이후인지 여부입니다.
    private var isSelectedFuture: Bool {
        calendar.startOfDay(for: selectedDate) > calendar.startOfDay(for: today)
    }

    /// 선택한 날짜의 미리보기 헤더 문구를 만듭니다.
    ///
    /// "월 일 요일" 형태이며, 오늘이면서 회고가 없으면 앞에 "오늘 · "을, 회고가 둘 이상이면 뒤에 개수를 붙입니다.
    ///
    /// - Parameter count: 선택한 날짜의 회고 수입니다.
    /// - Returns: 헤더 문구입니다.
    private func previewHeader(count: Int) -> String {
        var text = selectedDate.formatted(.dateTime.month().day().weekday(.wide).locale(.korean))
        if isSelectedToday && count == 0 { text = "오늘 · " + text }
        if count > 1 { text += " · \(count)개" }
        return text
    }

    /// 선택한 날짜 상태(미래, 오늘, 지난 날)에 맞는 빈 날 카드의 문구를 반환합니다.
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

    /// 날짜에서 시와 분을 한국어 형식으로 만듭니다.
    ///
    /// - Parameter date: 변환할 날짜입니다.
    /// - Returns: 시각 문자열입니다.
    private func timeText(_ date: Date) -> String {
        date.formatted(.dateTime.hour().minute().locale(.korean))
    }

    /// 보고 있는 달의 회고 요약 문구입니다.
    private var monthSummary: String {
        Retrospective.monthSummary(of: retrospectives, month: displayedMonth)
    }

    /// 보고 있는 달을 지정한 개월 수만큼 이동합니다.
    ///
    /// 이동한 달이 이번 달이면 오늘을, 아니면 그 달의 첫날을 선택 날짜로 지정합니다.
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

/// 선택한 날의 회고 하나를 감정 아우라와 한 줄 내용으로 보여주는 미리보기 카드입니다.
private struct RetroPreviewCard: View {
    /// 카드에 표시할 감정입니다.
    let emotion: Emotion
    /// 카드의 제목 문구입니다.
    let title: String
    /// 카드에 표시할 회고 내용이며 한 줄까지만 보여줍니다.
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
