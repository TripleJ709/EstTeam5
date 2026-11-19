import SwiftData
import SwiftUI

struct RetrospectiveListView: View {
    @Query(sort: \Retrospective.date, order: .reverse)
    private var retrospectives: [Retrospective]

    @State private var displayedMonth = Date.now
    @State private var selectedDate = Date.now
    @State private var writeRequest: WriteRequest?
    @State private var isShowingThemeAlert = false
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    private var calendar: Calendar { .current }
    private var today: Date { .now }

    private struct WriteRequest: Identifiable {
        let id = UUID()
        let date: Date
    }

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

    private func legendItem(_ emotion: Emotion) -> some View {
        HStack(spacing: 4) {
            EmotionAuraView(emotion: emotion, size: 10, showsFace: false)
            Text(emotion.displayName)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
                .fixedSize()
        }
    }

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

    private var selectedDayItems: [Retrospective] {
        retrospectives
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var isSelectedToday: Bool { calendar.isDate(selectedDate, inSameDayAs: today) }

    private var isSelectedFuture: Bool {
        calendar.startOfDay(for: selectedDate) > calendar.startOfDay(for: today)
    }

    private func previewHeader(count: Int) -> String {
        var text = selectedDate.formatted(.dateTime.month().day().weekday(.wide).locale(.korean))
        if isSelectedToday && count == 0 { text = "오늘 · " + text }
        if count > 1 { text += " · \(count)개" }
        return text
    }

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

    private func timeText(_ date: Date) -> String {
        date.formatted(.dateTime.hour().minute().locale(.korean))
    }

    private var monthSummary: String {
        Retrospective.monthSummary(of: retrospectives, month: displayedMonth)
    }

    private func moveMonth(by value: Int) {
        guard let moved = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = moved
        if let start = calendar.dateInterval(of: .month, for: moved)?.start {
            selectedDate = calendar.isDate(moved, equalTo: today, toGranularity: .month) ? today : start
        }
    }
}

private struct RetroPreviewCard: View {
    let emotion: Emotion
    let title: String
    let content: String

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
