import SwiftData
import SwiftUI

/// 회고를 새로 작성하거나 기존 회고를 편집하는 화면입니다.
///
/// 날짜, 감정, 회고 내용을 입력하고, 회고 내용을 바탕으로 AI 감정 추천을 받을 수 있습니다.
struct RetrospectiveWriteView: View {
    /// 편집할 기존 회고입니다. `nil`이면 새 회고를 작성합니다.
    var retrospective: Retrospective?

    /// 회고 저장에 사용하는 SwiftData 모델 컨텍스트입니다.
    @Environment(\.modelContext) private var modelContext
    /// 현재 화면을 닫는 동작입니다.
    @Environment(\.dismiss) private var dismiss
    /// 현재 Dynamic Type 글자 크기 설정입니다.
    @Environment(\.dynamicTypeSize) private var typeSize
    /// AI 아이콘의 크기이며 본문 글꼴 크기에 비례해 조절됩니다.
    @ScaledMetric(relativeTo: .body) private var aiIconSize: CGFloat = 20

    /// 사용자가 입력 중인 초안입니다.
    @State private var draft: RetrospectiveDraft
    /// 화면을 열었을 때의 초안이며 변경 여부를 비교하는 기준입니다.
    @State private var originalDraft: RetrospectiveDraft
    /// 변경 사항 버리기 확인 알림 표시 여부입니다.
    @State private var isConfirmingDiscard = false
    /// 날짜 선택 팝오버 표시 여부입니다.
    @State private var isShowingDatePicker = false
    /// AI 감정 추천의 진행 상태입니다.
    @State private var recommendation: RecommendationState = .idle
    /// 진행 중인 AI 감정 추천 작업이며 화면이 사라질 때 취소됩니다.
    @State private var recommendTask: Task<Void, Never>?

    /// AI 감정 추천을 요청하는 객체입니다.
    private let recommender = EmotionRecommender()
    /// 감정 선택 격자의 열 정의입니다. 기본 4열이고, 접근성 글자 크기에서는 2열, `xxLarge` 이상에서는 3열입니다.
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
    /// `retrospective`가 있으면 그 내용으로 초안을 만들고, 없으면 `date`(없으면 현재 시각)로 빈 초안을 만듭니다.
    ///
    /// - Parameters:
    ///   - retrospective: 편집할 기존 회고입니다. 기본값은 `nil`입니다.
    ///   - date: 새 회고의 초기 날짜입니다. 기본값은 `nil`입니다.
    init(retrospective: Retrospective? = nil, date: Date? = nil) {
        self.retrospective = retrospective
        let initialDraft: RetrospectiveDraft
        if let retrospective {
            initialDraft = RetrospectiveDraft(retrospective)
        } else {
            initialDraft = RetrospectiveDraft(date: date ?? .now)
        }
        _draft = State(initialValue: initialDraft)
        _originalDraft = State(initialValue: initialDraft)
    }

    // 화면을 열었을 때와 내용이 달라졌으면 true
    /// 화면을 열었을 때와 내용이 달라졌으면 `true`입니다.
    private var hasChanges: Bool {
        draft != originalDraft
    }

    /// 화면 구성
    var body: some View {
        ZStack(alignment: .top) {
            Color.bgApp
                .overlay(alignment: .top) {
                    if let emotion = draft.emotion {
                        EmotionWash(emotion: emotion, opacity: 0.55, blur: 30)
                            .offset(y: -200)
                            .animation(.easeInOut(duration: 0.25), value: draft.emotion)
                    }
                }
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    dateSection
                    emotionSection
                    recommendSection
                    contentSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onDisappear { recommendTask?.cancel() }
        .navigationTitle(retrospective == nil ? "새 감정" : "감정 편집")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    if hasChanges {
                        isConfirmingDiscard = true
                    } else {
                        dismiss()
                    }
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
        .alert("작성 중인 회고가 있어요", isPresented: $isConfirmingDiscard) {
            Button("변경 사항 버리기", role: .destructive) {
                dismiss()
            }
            Button("계속 작성하기", role: .cancel) {}
        } message: {
            Text("닫으면 입력한 내용이 사라져요.")
        }
        .interactiveDismissDisabled(hasChanges)
        .tint(Color.tintPrimary)
        .presentationDetents([.large])
        .presentationCornerRadius(38)
        .presentationBackground(Color.bgApp)
    }

    /// 날짜 라벨과 날짜 선택 버튼을 보여주는 영역입니다.
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

    // 기본(compact) DatePicker는 다른 날짜를 고르면 달력 숫자 칸이 살짝 넓어져서
    // 날짜 버튼 + popover 안의 달력(graphical)으로 직접 띄움
    /// 선택한 날짜를 표시하고, 누르면 달력 팝오버를 띄우는 버튼입니다.
    private var datePicker: some View {
        Button {
            isShowingDatePicker = true
        } label: {
            Text(draft.date.formatted(.dateTime.year().month(.defaultDigits).day().locale(.korean)))
                .monospacedDigit()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemFill), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("날짜")
        .accessibilityValue(draft.date.formatted(.dateTime.year().month().day().locale(.korean)))
        .popover(isPresented: $isShowingDatePicker) {
            DatePicker("날짜", selection: $draft.date, in: ...Date.now, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .environment(\.locale, .korean)
                // 7칸이 정수(46pt)로 나눠지는 폭: 소수점 폭이면 처음 열 때와 날짜를 고른 뒤 칸 위치가 1pt쯤 달라짐
                .frame(width: 322)
                .padding(.horizontal, 12)
                .presentationCompactAdaptation(.popover)
        }
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

    /// 회고 내용을 입력하는 텍스트 편집기와 글자 수를 보여주는 영역입니다.
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

    /// AI 감정 추천 버튼과 추천 결과를 보여주는 영역입니다.
    private var recommendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                recommend()
            } label: {
                HStack(spacing: 8) {
                    if recommendation == .loading {
                        ProgressView()
                    } else {
                        Image(decorative: "iconAI")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: aiIconSize, height: aiIconSize)
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

    /// AI 추천 결과 또는 실패 메시지를 보여주는 영역입니다. 추천 결과는 선택된 감정이 추천 감정과 같을 때만 표시합니다.
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

    /// 회고 내용으로 AI 감정 추천을 요청합니다.
    ///
    /// 성공하면 추천 감정을 초안에 반영하고, 취소되면 대기 상태로 돌아가며, 오류가 나면 실패 메시지를 상태에 저장합니다.
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

    /// 입력한 내용을 저장하고 화면을 닫습니다.
    ///
    /// 감정이 선택되지 않았으면 아무 일도 하지 않습니다. 기존 회고가 있으면 날짜(기존 시각 유지), 내용, 감정을 갱신하고, 없으면 새 회고를 추가합니다.
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
    /// 추천을 요청하지 않은 초기 상태입니다.
    case idle
    /// 추천 결과를 기다리는 상태입니다.
    case loading
    /// 추천이 완료된 상태이며 추천 결과를 담습니다.
    case recommended(EmotionRecommendation)
    /// 추천이 실패한 상태이며 사용자에게 보여줄 메시지를 담습니다.
    case failed(String)
}

/// 감정 하나를 선택 카드로 보여주는 뷰입니다.
private struct EmotionPickerCard: View {
    /// 카드에 표시할 감정입니다.
    let emotion: Emotion
    /// 카드의 선택 여부입니다.
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
