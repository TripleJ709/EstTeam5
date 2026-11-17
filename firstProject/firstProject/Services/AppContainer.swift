import Foundation
import SwiftData

/// 앱의 SwiftData 컨테이너.
/// 디버그 빌드에서 `-seedSample` 인자를 주면 시안용 샘플을 메모리 DB에 넣는다(`DebugSample` 참고).
/// 실제 저장소에는 아무것도 쓰지 않는다.
@MainActor
enum AppContainer {
    static let shared: ModelContainer = make()

    private static func make() -> ModelContainer {
        #if DEBUG
        if DebugSample.isSeeding {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            if let container = try? ModelContainer(for: Retrospective.self, configurations: config) {
                DebugSample.seed(container.mainContext)
                return container
            }
        }
        #endif
        do {
            return try ModelContainer(for: Retrospective.self)
        } catch {
            fatalError("SwiftData 컨테이너를 만들 수 없습니다: \(error)")
        }
    }
}
