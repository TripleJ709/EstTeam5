import Foundation
import Observation

/// 주간 분석 요청의 진행 상태입니다.
enum WeeklyAnalysisState: Equatable {
    /// 아직 분석을 요청하지 않은 상태입니다.
    case idle
    /// 분석 요청이 진행 중인 상태입니다.
    case loading
    /// 분석이 완료되어 결과를 가진 상태입니다.
    case loaded(WeeklyReflectionAnalysis)
    /// 분석이 실패한 상태이며, 사용자에게 보여줄 오류 메시지를 가집니다.
    case failed(String)

    /// 현재 상태가 `.loaded`인지 여부입니다.
    var isLoaded: Bool {
        switch self {
        case .loaded: true
        default: false
        }
    }
}

/// 주간 회고 분석의 상태를 관리하는 저장소입니다.
///
/// `WeeklyReflectionAnalyzer`로 분석을 요청하고 진행 상태와 결과를 `state`에 보관합니다.
@Observable
final class WeeklyAnalysisStore {
    /// 현재 분석 상태입니다. 외부에서는 읽기만 가능합니다.
    private(set) var state: WeeklyAnalysisState = .idle

    /// 진행 중인 분석 작업입니다.
    private var task: Task<Void, Never>?
    /// 분석을 수행하는 분석기입니다.
    private let analyzer: WeeklyReflectionAnalyzer

    /// 저장소를 생성합니다.
    ///
    /// - Parameter analyzer: 분석에 사용할 분석기입니다. 기본값은 새 `WeeklyReflectionAnalyzer`입니다.
    init(analyzer: WeeklyReflectionAnalyzer = WeeklyReflectionAnalyzer()) {
        self.analyzer = analyzer
    }

    /// 주간 회고 분석을 시작합니다.
    ///
    /// 이미 `.loading` 상태이면 아무 동작도 하지 않습니다. 그렇지 않으면 상태를 `.loading`으로 바꾸고 비동기로 분석합니다.
    /// 성공하면 `.loaded`, `AIServerError`가 발생하면 해당 오류의 사용자 메시지와 함께 `.failed`가 됩니다.
    /// 그 밖의 오류는 응답 오류(`invalidResponse`) 메시지로 `.failed`가 되며, 작업이 취소된 경우에는 상태를 바꾸지 않습니다.
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
            } catch let error as AIServerError {
                guard !Task.isCancelled else { return }
                state = .failed(error.userMessage(for: WeeklyReflectionAnalyzer.feature))
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed(AIServerError.invalidResponse.userMessage(for: WeeklyReflectionAnalyzer.feature))
            }
        }
    }

    /// 진행 중인 작업을 취소하고 상태를 `.idle`로 되돌립니다.
    func reset() {
        task?.cancel()
        task = nil
        state = .idle
    }
}
