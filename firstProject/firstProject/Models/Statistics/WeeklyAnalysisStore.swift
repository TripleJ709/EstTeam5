import Foundation
import Observation

/// 주간 분석 요청의 진행 상태를 나타냅니다.
enum WeeklyAnalysisState: Equatable {
    /// 아직 분석을 요청하지 않았거나 초기화된 상태입니다.
    case idle
    /// 분석을 진행 중인 상태입니다.
    case loading
    /// 분석이 끝난 상태입니다. 분석 결과를 함께 담습니다.
    case loaded(WeeklyReflectionAnalysis)
    /// 분석이 실패한 상태입니다. 사용자에게 보여줄 오류 메시지를 함께 담습니다.
    case failed(String)

    /// 분석이 완료(`loaded`)된 상태인지 여부입니다.
    var isLoaded: Bool {
        switch self {
        case .loaded: true
        default: false
        }
    }
}

/// 주간 분석 요청을 실행하고 상태를 보관하는 저장소입니다.
@Observable
final class WeeklyAnalysisStore {
    /// 현재 분석 상태입니다. 외부에서는 읽기만 가능합니다.
    private(set) var state: WeeklyAnalysisState = .idle

    /// 진행 중인 분석 작업입니다.
    private var task: Task<Void, Never>?
    /// 분석을 수행하는 `WeeklyReflectionAnalyzer`입니다.
    private let analyzer: WeeklyReflectionAnalyzer

    /// 저장소를 생성합니다.
    ///
    /// - Parameter analyzer: 분석에 사용할 분석기입니다. 기본값은 `WeeklyReflectionAnalyzer()`입니다.
    init(analyzer: WeeklyReflectionAnalyzer = WeeklyReflectionAnalyzer()) {
        self.analyzer = analyzer
    }

    /// 주간 회고 입력을 분석하고 결과에 따라 `state`를 갱신합니다.
    ///
    /// 이미 `loading` 상태이면 아무 작업도 하지 않습니다. 시작하면 `loading`으로 바꾸고, 성공하면 `loaded`로 바꿉니다. 작업이 취소되면 상태를 바꾸지 않으며, 그 외 오류는 `failed`에 오류 메시지를 담아 바꿉니다.
    ///
    /// - Parameter input: 분석할 주간 회고 입력입니다.
    func analyze(_ input: WeeklyReflectionInput) {
        guard state != .loading else { return }
        state = .loading
        task = Task {
            do {
                let result = try await analyzer.analyze(input)
                guard !Task.isCancelled else { return }
                state = .loaded(result)
            } catch is CancellationError {
                return
            } catch let error as OpenAIError {
                guard !Task.isCancelled else { return }
                state = .failed(error.userMessage(for: WeeklyReflectionAnalyzer.feature))
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed(OpenAIError.invalidResponse.userMessage(for: WeeklyReflectionAnalyzer.feature))
            }
        }
    }

    /// 진행 중인 분석 작업을 취소하고 상태를 `idle`로 되돌립니다.
    func reset() {
        task?.cancel()
        task = nil
        state = .idle
    }
}
