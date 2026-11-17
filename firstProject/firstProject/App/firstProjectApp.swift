import SwiftData
import SwiftUI

@main
struct firstProjectApp: App {
    #if DEBUG
    // 개발 중에는 실행할 때마다 첫 실행 화면을 보여준다(저장하지 않음).
    // 실행 인자 `-skipWelcome`을 주면 바로 메인 화면으로 들어간다.
    @State private var hasSeenWelcome = CommandLine.arguments.contains("-skipWelcome")
    #else
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    #endif

    var body: some Scene {
        WindowGroup {
            if hasSeenWelcome {
                MainTabView()
            } else {
                WelcomeView { hasSeenWelcome = true }
            }
        }
        .modelContainer(AppContainer.shared)
    }
}
