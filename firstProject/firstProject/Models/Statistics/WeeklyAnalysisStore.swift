import Foundation
import Observation

/// 주간 AI 분석의 진행 상태입니다.
enum WeeklyAnalysisState: Equatable {
    /// 아직 분석하지 않았거나 초기화된 상태입니다.
    case idle
    /// 분석 요청을 보내고 응답을 기다리는 상태입니다.
    case loading
    /// 분석이 끝난 상태입니다. 결과를 함께 담습니다.
    case loaded(WeeklyReflectionAnalysis)
    /// 분석에 실패한 상태입니다. 화면에 보여 줄 안내 문구를 함께 담습니다.
    case failed(String)

    /// 분석 결과가 있는지 여부입니다.
    var isLoaded: Bool {
        switch self {
        case .loaded: true
        default: false
        }
    }
}

/// 주간 AI 분석의 상태를 관리하고 요청과 취소를 맡는 저장소입니다.
///
/// 화면은 `state`만 읽고, 분석은 `analyze(_:)`로 시작하고 `reset()`으로 초기화합니다.
/// 요청 중에 `reset()`을 부르면 진행 중인 요청을 취소하고, 늦게 도착한 결과는 버립니다.
@Observable
final class WeeklyAnalysisStore {
    /// 현재 분석 상태입니다. 읽기만 할 수 있습니다.
    private(set) var state: WeeklyAnalysisState = .idle

    private var task: Task<Void, Never>?
    private let analyzer: WeeklyReflectionAnalyzer

    /// 저장소를 만듭니다.
    ///
    /// - Parameter analyzer: 분석을 수행할 객체. 기본값은 기본 설정의 분석기입니다.
    init(analyzer: WeeklyReflectionAnalyzer = WeeklyReflectionAnalyzer()) {
        self.analyzer = analyzer
    }

    /// 한 주의 회고를 AI로 분석합니다.
    ///
    /// 이미 분석 중이면 무시합니다. 결과나 오류는 `state`로 확인합니다.
    ///
    /// - Parameter input: 분석할 한 주의 회고와 앱이 계산한 통계.
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

    /// 진행 중인 분석을 취소하고 `idle` 상태로 되돌립니다.
    ///
    /// 보고 있는 주나 기간이 바뀔 때 부릅니다.
    func reset() {
        task?.cancel()
        task = nil
        state = .idle
    }
}
