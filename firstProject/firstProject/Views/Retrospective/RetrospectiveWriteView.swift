import SwiftData
import SwiftUI

struct RetrospectiveWriteView: View {
    var retrospective: Retrospective?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var draft: RetrospectiveDraft
    @State private var recommendation: RecommendationState = .idle
    @State private var recommendTask: Task<Void, Never>?

    private let recommender = EmotionRecommender()
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    init(retrospective: Retrospective? = nil, date: Date? = nil) {
        self.retrospective = retrospective
        _draft = State(initialValue: retrospective.map(RetrospectiveDraft.init) ?? RetrospectiveDraft(date: date ?? .now))
    }

    var body: some View {
        ZStack(alignment: .top) {
            FeeloColor.bgApp.ignoresSafeArea()

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
        .tint(FeeloColor.tint)
        .presentationDetents([.large])
        .presentationCornerRadius(38)
        .presentationBackground(FeeloColor.bgApp)
    }

    // MARK: - Sections

    private var dateSection: some View {
        DatePicker("날짜", selection: $draft.date, in: ...Date.now, displayedComponents: .date)
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
                    EmotionPickerCard(emotion: item, isSelected: item == draft.emotion) {
                        draft.emotion = item
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
                TextEditor(text: $draft.content)
                    .font(.body)
                    .foregroundStyle(FeeloColor.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .onChange(of: draft.content) {
                        draft.clampContent()
                    }

                Text("\(draft.content.count) / \(RetrospectiveDraft.maxLength)")
                    .font(.footnote)
                    .foregroundStyle(FeeloColor.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.card))
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
                .font(.footnote)
                .padding(.horizontal, 16)
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var recommendationNote: some View {
        switch recommendation {
        case .recommended(let emotion) where draft.emotion == emotion:
            Text("AI가 \(emotion.displayName) 감정을 추천했어요. 위에서 직접 바꿀 수도 있어요.")
                .foregroundStyle(FeeloColor.textSecondary)
        case .failed(let message):
            Text(message)
                .foregroundStyle(.red)
        default:
            Text("")
                .foregroundStyle(FeeloColor.textSecondary)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(FeeloColor.textSecondary)
            .padding(.horizontal, 16)
    }

    // MARK: - Recommend

    private func recommend() {
        guard draft.canRecommend, recommendation != .loading else { return }
        let content = draft.trimmedContent
        recommendation = .loading
        recommendTask = Task {
            do {
                let emotion = try await recommender.recommend(for: content)
                draft.emotion = emotion
                recommendation = .recommended(emotion)
            } catch is CancellationError {
                recommendation = .idle
            } catch let error as EmotionRecommenderError {
                recommendation = .failed(error.userMessage)
            } catch {
                recommendation = .failed(EmotionRecommenderError.invalidResponse.userMessage)
            }
        }
    }

    // MARK: - Save

    private func save() {
        guard let emotion = draft.emotion else { return }

        if let retrospective {
            // 날짜를 바꿔도 기존 작성 시각(시·분)은 유지한다.
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
    case recommended(Emotion)
    case failed(String)
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
