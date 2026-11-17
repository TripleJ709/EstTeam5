import SwiftData
import SwiftUI

struct RetrospectiveListView: View {
    @Query(sort: \Retrospective.date, order: .reverse)
    private var retrospectives: [Retrospective]

    @State private var displayedMonth = Date.now
    @State private var selectedDate = Date.now

    private var calendar: Calendar { .current }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(monthSummary)
                        .font(.subheadline)
                        .foregroundStyle(FeeloColor.textSecondary)
                        .padding(.horizontal, 16)

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
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        RetrospectiveWriteView()
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("회고 작성")
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var monthNavigation: some View {
        HStack(spacing: 0) {
            Text(displayedMonth.formatted(.dateTime.year().month(.defaultDigits).locale(Locale(identifier: "ko_KR"))))
                .font(.title3.weight(.medium))
                .foregroundStyle(FeeloColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            monthButton(systemName: "chevron.left", label: "이전 달", offset: -1)
            monthButton(systemName: "chevron.right", label: "다음 달", offset: 1)
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
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
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var selectedDayPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selectedDate.formatted(.dateTime.month().day().weekday(.wide).locale(Locale(identifier: "ko_KR"))))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(FeeloColor.textSecondary)
                .padding(.horizontal, 16)

            if let item = latestRetrospective(on: selectedDate) {
                NavigationLink {
                    RetrospectiveDetailView(retrospective: item)
                } label: {
                    RetroPreviewCard(emotion: item.emotion, content: item.content)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            } else {
                Text("이 날의 기록이 없어요")
                    .font(.subheadline)
                    .foregroundStyle(FeeloColor.textSecondary)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Data

    private var monthRetrospectives: [Retrospective] {
        retrospectives.filter { calendar.isDate($0.date, equalTo: displayedMonth, toGranularity: .month) }
    }

    /// "이번 달은 기쁨이 가장 많았어요 · 13개의 기록"
    private var monthSummary: String {
        let items = monthRetrospectives
        guard !items.isEmpty else { return "이번 달은 아직 기록이 없어요" }
        let counts = Dictionary(grouping: items, by: \.emotion).mapValues(\.count)
        // 동률이면 Emotion 선언 순서가 앞선 감정을 고른다.
        let top = Emotion.allCases.max { (counts[$0] ?? 0) < (counts[$1] ?? 0) } ?? .fallback
        return "이번 달은 \(top.displayName)\(top.subjectParticle) 가장 많았어요 · \(items.count)개의 기록"
    }

    private func latestRetrospective(on date: Date) -> Retrospective? {
        retrospectives
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .max { $0.createdAt < $1.createdAt }
    }

    private func moveMonth(by value: Int) {
        guard let moved = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = moved
        // 선택한 날짜가 보이는 달을 벗어나지 않도록 같은 달의 1일로 옮긴다.
        if let start = calendar.dateInterval(of: .month, for: moved)?.start {
            selectedDate = calendar.isDate(moved, equalTo: .now, toGranularity: .month) ? .now : start
        }
    }
}

// MARK: - Preview card

private struct RetroPreviewCard: View {
    let emotion: Emotion
    let content: String

    var body: some View {
        HStack(spacing: 12) {
            EmotionAuraView(emotion: emotion, size: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(emotion.displayName)
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

private extension Emotion {
    /// 받침 유무에 따라 주격 조사 "이/가"를 돌려준다.
    var subjectParticle: String {
        guard let last = displayName.unicodeScalars.last,
              (0xAC00...0xD7A3).contains(last.value) else { return "이" }
        return (last.value - 0xAC00) % 28 == 0 ? "가" : "이"
    }
}

#Preview {
    RetrospectiveListView()
        .modelContainer(for: Retrospective.self, inMemory: true)
}
