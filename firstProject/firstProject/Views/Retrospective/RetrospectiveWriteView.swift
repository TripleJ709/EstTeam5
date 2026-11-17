import SwiftData
import SwiftUI

/// 회고 작성·편집 시트 (Figma "제안 C · 회고 작성")
/// `retrospective`가 있으면 편집, 없으면 새 회고를 만든다.
struct RetrospectiveWriteView: View {
    static let maxLength = 500

    var retrospective: Retrospective?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date
    @State private var emotion: Emotion?
    @State private var content: String

    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    init(retrospective: Retrospective? = nil) {
        self.retrospective = retrospective
        _date = State(initialValue: retrospective?.date ?? .now)
        _emotion = State(initialValue: retrospective?.emotion)
        _content = State(initialValue: retrospective?.content ?? "")
    }

    private var canSave: Bool {
        emotion != nil && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack(alignment: .top) {
            FeeloColor.bgApp.ignoresSafeArea()

            // 선택한 감정 색이 시트 위쪽에 은은하게 번진다.
            if let emotion {
                EmotionWash(emotion: emotion, opacity: 0.55, blur: 30)
                    .frame(maxWidth: .infinity)
                    .offset(y: -200)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.25), value: emotion)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    dateSection
                    emotionSection
                    contentSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle(retrospective == nil ? "새 회고" : "회고 편집")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .accessibilityLabel("닫기")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    save()
                } label: {
                    Image(systemName: "checkmark")
                        .accessibilityLabel("저장")
                }
                .disabled(!canSave)
            }
        }
        .tint(FeeloColor.tint)
        .presentationDetents([.large])
        .presentationCornerRadius(38)
        .presentationBackground(FeeloColor.bgApp)
    }

    // MARK: - Sections

    private var dateSection: some View {
        DatePicker("날짜", selection: $date, in: ...Date.now, displayedComponents: .date)
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .foregroundStyle(FeeloColor.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.card))
            .padding(.top, 8)
    }

    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionTitle("오늘의 감정")
                .padding(.top, 8)

            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(Emotion.allCases) { item in
                    EmotionPickerCard(emotion: item, isSelected: item == emotion) {
                        emotion = item
                    }
                }
            }
            .padding(12)
            .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.card))

            Text("오늘 하루를 가장 잘 나타내는 감정을 하나 골라 주세요.")
                .font(.footnote)
                .foregroundStyle(FeeloColor.textSecondary)
                .padding(.horizontal, 16)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionTitle("회고")
                .padding(.top, 8)

            VStack(alignment: .trailing, spacing: 8) {
                TextEditor(text: $content)
                    .font(.body)
                    .foregroundStyle(FeeloColor.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .onChange(of: content) { _, newValue in
                        if newValue.count > Self.maxLength {
                            content = String(newValue.prefix(Self.maxLength))
                        }
                    }

                Text("\(content.count) / \(Self.maxLength)")
                    .font(.footnote)
                    .foregroundStyle(FeeloColor.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.card))
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(FeeloColor.textSecondary)
            .padding(.horizontal, 16)
    }

    // MARK: - Save

    private func save() {
        guard let emotion else { return }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let calendar = Calendar.current

        if let retrospective {
            // 날짜를 바꿔도 기존 작성 시각(시·분)은 유지한다.
            retrospective.date = combine(day: date, timeFrom: retrospective.date, calendar: calendar)
            retrospective.content = trimmed
            retrospective.emotion = emotion
        } else {
            let newItem = Retrospective(
                date: combine(day: date, timeFrom: .now, calendar: calendar),
                content: trimmed,
                emotion: emotion
            )
            modelContext.insert(newItem)
        }
        dismiss()
    }

    private func combine(day: Date, timeFrom time: Date, calendar: Calendar) -> Date {
        var parts = calendar.dateComponents([.year, .month, .day], from: day)
        let timeParts = calendar.dateComponents([.hour, .minute, .second], from: time)
        parts.hour = timeParts.hour
        parts.minute = timeParts.minute
        parts.second = timeParts.second
        return calendar.date(from: parts) ?? day
    }
}

// MARK: - Emotion picker card

private struct EmotionPickerCard: View {
    let emotion: Emotion
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                EmotionAuraView(emotion: emotion, size: 36)
                Text(emotion.displayName)
                    .font(.footnote)
                    .foregroundStyle(FeeloColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.top, 12)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? FeeloColor.bgSelected : FeeloColor.bgApp,
                in: RoundedRectangle(cornerRadius: FeeloRadius.control)
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: FeeloRadius.control)
                        .strokeBorder(FeeloColor.tint, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(emotion.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        RetrospectiveWriteView()
    }
    .modelContainer(for: Retrospective.self, inMemory: true)
}
