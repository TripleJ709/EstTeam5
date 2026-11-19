import Foundation
import Observation

enum WeeklyAnalysisState: Equatable {
    case idle
    case loading
    case loaded(WeeklyReflectionAnalysis)
    case failed(String)

    var isLoaded: Bool {
        switch self {
        case .loaded: true
        default: false
        }
    }
}

@Observable
final class WeeklyAnalysisStore {
    private(set) var state: WeeklyAnalysisState = .idle

    private var task: Task<Void, Never>?
    private let analyzer: WeeklyReflectionAnalyzer

    init(analyzer: WeeklyReflectionAnalyzer = WeeklyReflectionAnalyzer()) {
        self.analyzer = analyzer
    }

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

    func reset() {
        task?.cancel()
        task = nil
        state = .idle
    }
}
