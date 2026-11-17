import SwiftData
import SwiftUI

struct RetrospectiveListView: View {
    @Query(sort: \Retrospective.date, order: .reverse)
    private var retrospectives: [Retrospective]

    @State private var displayedMonth = Self.initialSelectedDate
    @State private var selectedDate = Self.initialSelectedDate
    @State private var writeRequest: WriteRequest?

    private var calendar: Calendar { .current }
    private var today: Date { AppClock.now }

    /// 작성 시트를 열 때 채워 둘 날짜
    private struct WriteRequest: Identifiable {
        let id = UUID()
        let date: Date
    }

    private static var initialSelectedDate: Date {
        #if DEBUG
        if DebugSample.isSeeding { return DebugSample.selectedDate }
        #endif
        return AppClock.now
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(monthSummary)
                        .font(.subheadline)
                        .foregroundStyle(FeeloColor.textSecondary)
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
            .background(FeeloColor.bgApp.ignoresSafeArea())
            .navigationTitle("회고")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // 화면 설정(테마·글꼴) 시트는 05 화면 구현 때 연결한다.
                    Button {} label: {
                        Image(systemName: "circle.lefthalf.filled")
                            .accessibilityLabel("화면 설정")
                    }
                    .tint(FeeloColor.tint)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        writeRequest = WriteRequest(date: today)
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("회고 작성")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(FeeloColor.tint)
                }
            }
            .sheet(item: $writeRequest) { request in
                NavigationStack {
                    RetrospectiveWriteView(date: request.date)
                }
            }
        }
    }

    // MARK: - Sections

    private var monthNavigation: some View {
        HStack(spacing: 0) {
            Text(displayedMonth.formatted(.dateTime.year().month(.wide).locale(Locale(identifier: "ko_KR"))))
                .font(.title3.weight(.medium))
                .foregroundStyle(FeeloColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            monthButton(systemName: "chevron.left", label: "이전 달", offset: -1)
            monthButton(systemName: "chevron.right", label: "다음 달", offset: 1)
        }
        .padding(.top, 12)
        .padding(.leading, 16)
        .padding(.trailing, 4)
    }

    private func monthButton(systemName: String, label: String, offset: Int) -> some View {
        Button {
            moveMonth(by: offset)
        } label: {
            Image(systemName: systemName)
                .font(.title3.weight(.medium))
                .foregroundStyle(FeeloColor.tint)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(label)
    }

    private var legend: some View {
        HStack(spacing: 10) {
            ForEach(Emotion.allCases) { emotion in
                HStack(spacing: 4) {
                    EmotionAuraView(emotion: emotion, size: 10)
                    Text(emotion.displayName)
                        .font(.caption)
                        .foregroundStyle(FeeloColor.textSecondary)
                        .fixedSize()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.top, 1)
        .accessibilityHidden(true)
    }

    private var selectedDayPreview: some View {
        let items = selectedDayItems
        return VStack(alignment: .leading, spacing: 0) {
            Text(previewHeader(count: items.count))
                .font(.system(size: 15, weight: .medium))
                .tracking(-0.23)
                .foregroundStyle(FeeloColor.textSecondary)
                .frame(height: 42)
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

    // MARK: - Data

    /// 선택한 날의 기록. 같은 날 여러 개면 최신순으로 모두 보여준다.
    private var selectedDayItems: [Retrospective] {
        retrospectives
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var isSelectedToday: Bool { calendar.isDate(selectedDate, inSameDayAs: today) }

    private var isSelectedFuture: Bool {
        calendar.startOfDay(for: selectedDate) > calendar.startOfDay(for: today)
    }

    /// "오늘 · 11월 16일 월요일 · 2개" 형식의 헤더
    private func previewHeader(count: Int) -> String {
        var text = selectedDate.formatted(.dateTime.month().day().weekday(.wide).locale(Locale(identifier: "ko_KR")))
        if isSelectedToday && count == 0 { text = "오늘 · " + text }
        if count > 1 { text += " · \(count)개" }
        return text
    }

    /// 선택한 날에 기록이 없을 때의 안내 문구(지난 날, 오늘, 미래, 첫 사용)
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
        date.formatted(.dateTime.hour().minute().locale(Locale(identifier: "ko_KR")))
    }

    private var monthSummary: String {
        Retrospective.monthSummary(of: retrospectives, month: displayedMonth)
    }

    private func moveMonth(by value: Int) {
        guard let moved = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = moved
        // 선택한 날짜가 보이는 달을 벗어나지 않도록 이번 달이면 오늘, 아니면 그 달 1일로 옮긴다.
        if let start = calendar.dateInterval(of: .month, for: moved)?.start {
            selectedDate = calendar.isDate(moved, equalTo: today, toGranularity: .month) ? today : start
        }
    }
}

// MARK: - Preview card

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
                    .foregroundStyle(FeeloColor.textPrimary)
                Text(content)
                    .font(.subheadline)
                    .foregroundStyle(FeeloColor.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(FeeloColor.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            ZStack(alignment: .leading) {
                FeeloColor.bgCard
                // 카드 왼쪽에서 감정 색이 은은하게 번지는 배경
                Ellipse()
                    .fill(RadialGradient(colors: [emotion.auraStart, emotion.auraEnd],
                                         center: .center, startRadius: 0, endRadius: 36))
                    .frame(width: 72, height: 68)
                    .blur(radius: 18)
                    .opacity(0.3)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: FeeloRadius.card))
    }
}

#Preview {
    RetrospectiveListView()
        .modelContainer(for: Retrospective.self, inMemory: true)
}
