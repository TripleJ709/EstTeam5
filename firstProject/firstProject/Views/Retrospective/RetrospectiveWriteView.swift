import SwiftData
import SwiftUI

/// 회고를 새로 작성하거나 기존 회고를 편집하는 화면입니다.
///
/// 날짜, 감정, 회고 내용을 입력받고, 내용을 바탕으로 한 AI 감정 추천을 받을 수 있습니다.
struct RetrospectiveWriteView: View {
    /// 편집할 회고입니다. `nil`이면 새 회고를 작성합니다.
    var retrospective: Retrospective?

    /// 회고를 저장할 때 사용하는 SwiftData 모델 컨텍스트입니다.
    @Environment(\.modelContext) private var modelContext
    /// 현재 화면을 닫는 동작입니다.
    @Environment(\.dismiss) private var dismiss
    /// 현재 Dynamic Type(글자 크기) 설정입니다.
    @Environment(\.dynamicTypeSize) private var typeSize

    /// 입력 중인 날짜, 감정, 내용을 담은 초안입니다.
    @State private var draft: RetrospectiveDraft
    /// AI 감정 추천의 진행 상태입니다.
    @State private var recommendation: RecommendationState = .idle
    /// 진행 중인 AI 감정 추천 작업입니다. 화면이 사라질 때 취소합니다.
    @State private var recommendTask: Task<Void, Never>?

    /// AI 감정 추천을 요청하는 객체입니다.
    private let recommender = EmotionRecommender()
    /// 감정 선택 격자의 열 구성입니다. 기본 4열이고, 글자 크기가 `.xxLarge` 이상이면 3열, 접근성 크기이면 2열입니다.
    private var gridColumns: [GridItem] {
        var count = 4
        if typeSize.isAccessibilitySize {
            count = 2
        } else if typeSize >= .xxLarge {
            count = 3
        }
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: count)
    }

    /// 작성 화면을 초기화합니다.
    ///
    /// `retrospective`가 있으면 그 값으로 초안을 만들고, 없으면 `date`(없으면 현재 시각)로 빈 초안을 만듭니다.
    ///
    /// - Parameters:
    ///   - retrospective: 편집할 회고입니다. 새로 작성하면 `nil`입니다.
    ///   - date: 새 회고의 기본 날짜입니다. `nil`이면 현재 시각을 사용합니다.
    init(retrospective: Retrospective? = nil, date: Date? = nil) {
        self.retrospective = retrospective
        if let retrospective {
            _draft = State(initialValue: RetrospectiveDraft(retrospective))
        } else {
            _draft = State(initialValue: RetrospectiveDraft(date: date ?? .now))
        }
    }

    /// 화면 구성
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

    /// 회고 날짜를 선택하는 영역입니다. 접근성 크기에서는 세로로, 그 외에는 가로로 배치합니다.
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

    /// 오늘까지만 선택할 수 있는 날짜 선택기입니다.
    private var datePicker: some View {
        DatePicker("날짜", selection: $draft.date, in: ...Date.now, displayedComponents: .date)
            .labelsHidden()
            .environment(\.locale, .korean)
    }

    /// 감정을 고르는 카드 격자와 안내 문구를 보여주는 영역입니다.
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

    /// 회고 내용을 입력하는 텍스트 편집기와 글자 수 표시를 보여주는 영역입니다.
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

    /// AI 감정 추천 버튼과 추천 결과 안내를 보여주는 영역입니다.
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

    /// AI 추천 결과 또는 오류 메시지를 보여줍니다.
    ///
    /// 추천 결과는 현재 선택한 감정과 같을 때만 표시하고, 실패하면 오류 메시지를 표시합니다. 그 외 상태에서는 아무것도 표시하지 않습니다.
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

    /// 섹션 제목 텍스트를 만듭니다.
    ///
    /// - Parameter title: 표시할 제목입니다.
    /// - Returns: 제목 뷰입니다.
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.textSecondary)
            .padding(.horizontal, 16)
    }

    /// 회고 내용을 바탕으로 AI 감정 추천을 요청합니다.
    ///
    /// 내용이 비어 있거나 이미 로딩 중이면 아무 작업도 하지 않습니다. 성공하면 추천된 감정을 초안에 반영하고, 취소되면 대기 상태로 돌아가며, 실패하면 오류 메시지를 저장합니다.
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

    /// 초안을 저장하고 화면을 닫습니다.
    ///
    /// 감정이 선택되지 않았으면 아무 작업도 하지 않습니다. 편집 중이면 기존 회고의 날짜(시각 유지), 내용, 감정을 갱신하고, 새 작성이면 회고를 만들어 삽입합니다.
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

/// AI 감정 추천의 진행 상태입니다.
private enum RecommendationState: Equatable {
    /// 추천을 요청하지 않은 대기 상태입니다.
    case idle
    /// 추천 결과를 기다리는 중입니다.
    case loading
    /// 추천이 완료되었으며 결과를 담고 있습니다.
    case recommended(EmotionRecommendation)
    /// 추천이 실패했으며 사용자에게 보여줄 오류 메시지를 담고 있습니다.
    case failed(String)
}

/// 감정 하나를 선택하는 카드입니다.
private struct EmotionPickerCard: View {
    /// 카드가 나타내는 감정입니다.
    let emotion: Emotion
    /// 현재 선택된 상태인지 여부입니다.
    let isSelected: Bool
    /// 카드를 눌렀을 때 실행할 동작입니다.
    let action: () -> Void

    /// 화면 구성
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
