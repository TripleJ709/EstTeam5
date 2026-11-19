import SwiftData
import SwiftUI

struct RetrospectiveWriteView: View {
    var retrospective: Retrospective?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    @State private var draft: RetrospectiveDraft
    @State private var recommendation: RecommendationState = .idle
    @State private var recommendTask: Task<Void, Never>?

    private let recommender = EmotionRecommender()
    private var gridColumns: [GridItem] {
        var count = 4
        if typeSize.isAccessibilitySize {
            count = 2
        } else if typeSize >= .xxLarge {
            count = 3
        }
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: count)
    }

    init(retrospective: Retrospective? = nil, date: Date? = nil) {
        self.retrospective = retrospective
        if let retrospective {
            _draft = State(initialValue: RetrospectiveDraft(retrospective))
        } else {
            _draft = State(initialValue: RetrospectiveDraft(date: date ?? .now))
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.bgApp.ignoresSafeArea()

            if let emotion = draft.emotion {
                EmotionWash(emotion: emotion, opacity: 0.55, blur: 30)
                    .frame(maxWidth: .infinity)
                    .offset(y: -200)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.25), value: draft.emotion)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    dateSection
                    emotionSection
                    contentSection
                    recommendSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onDisappear { recommendTask?.cancel() }
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
                .disabled(!draft.canSave)
            }
        }
        .tint(Color.tintPrimary)
        .presentationDetents([.large])
        .presentationCornerRadius(38)
        .presentationBackground(Color.bgApp)
    }

    private var dateSection: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout())

        return layout {
            Text("날짜")
            if typeSize.isAccessibilitySize {
                datePicker
            } else {
                Spacer()
                datePicker
            }
        }
        .foregroundStyle(Color.textPrimary)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 26))
        .padding(.top, 8)
    }

    private var datePicker: some View {
        DatePicker("날짜", selection: $draft.date, in: ...Date.now, displayedComponents: .date)
            .labelsHidden()
            .environment(\.locale, .korean)
    }

    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionTitle("오늘의 감정")
                .padding(.top, 8)

            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(Emotion.allCases) { item in
                    EmotionPickerCard(emotion: item, isSelected: item == draft.emotion) {
                        draft.emotion = item
                    }
                }
            }
            .padding(12)
            .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 26))

            Text("오늘 하루를 가장 잘 나타내는 감정을 하나 골라 주세요.")
                .font(.footnote)
                .foregroundStyle(Color.textSecondary)
                .padding(.horizontal, 16)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionTitle("회고")
                .padding(.top, 8)

            VStack(alignment: .trailing, spacing: 8) {
                TextEditor(text: $draft.content)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .onChange(of: draft.content) {
                        draft.clampContent()
                    }

                Text("\(draft.content.count) / \(RetrospectiveDraft.maxLength)")
                    .font(.footnote)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.bgCard, in: RoundedRectangle(cornerRadius: 26))
        }
    }

    private var recommendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                recommend()
            } label: {
                HStack(spacing: 8) {
                    if recommendation == .loading {
                        ProgressView()
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(recommendation == .loading ? "감정을 분석하는 중" : "AI로 감정 추천받기")
                }
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .disabled(!draft.canRecommend || recommendation == .loading)

            recommendationNote
        }
        .padding(.top, 8)
        .animation(.easeInOut(duration: 0.2), value: recommendation)
        .animation(.easeInOut(duration: 0.2), value: draft.emotion)
    }

    @ViewBuilder
    private var recommendationNote: some View {
        switch recommendation {
        case .recommended(let result):
            if draft.emotion == result.emotion {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.tintPrimary)
                        Text("AI 추천 · \(result.emotion.displayName)")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.tintPrimary)
                    }

                    if !result.reason.isEmpty {
                        Text(result.reason)
                            .font(.subheadline)
                            .foregroundStyle(Color.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text("위에서 다른 감정을 직접 바꿀 수도 있어요.")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.bgSelected, in: RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.tintPrimary.opacity(0.35), lineWidth: 1)
                }
            }
        case .failed(let message):
            Text(message)
                .font(.footnote)
                .foregroundStyle(Color.statusDestructive)
                .padding(.horizontal, 16)
        default:
            EmptyView()
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.textSecondary)
            .padding(.horizontal, 16)
    }

    private func recommend() {
        guard draft.canRecommend, recommendation != .loading else { return }
        let content = draft.trimmedContent
        recommendation = .loading
        recommendTask = Task {
            do {
                let result = try await recommender.recommend(for: content)
                draft.emotion = result.emotion
                recommendation = .recommended(result)
            } catch is CancellationError {
                recommendation = .idle
            } catch let error as OpenAIError {
                recommendation = .failed(error.userMessage(for: EmotionRecommender.feature))
            } catch {
                recommendation = .failed(OpenAIError.invalidResponse.userMessage(for: EmotionRecommender.feature))
            }
        }
    }

    private func save() {
        guard let emotion = draft.emotion else { return }

        if let retrospective {
            retrospective.date = draft.combinedDate(timeFrom: retrospective.date)
            retrospective.content = draft.trimmedContent
            retrospective.emotion = emotion
        } else {
            let newItem = Retrospective(
                date: draft.combinedDate(timeFrom: .now),
                content: draft.trimmedContent,
                emotion: emotion
            )
            modelContext.insert(newItem)
        }
        dismiss()
    }
}

private enum RecommendationState: Equatable {
    case idle
    case loading
    case recommended(EmotionRecommendation)
    case failed(String)
}

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
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.top, 12)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? Color.bgSelected : Color.bgApp,
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.tintPrimary, lineWidth: 2)
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
