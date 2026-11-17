import SwiftData
import SwiftUI

@main
struct firstProjectApp: App {
    #if DEBUG
    // 개발 중에는 실행할 때마다 첫 실행 화면을 보여준다(저장하지 않음).
    @State private var hasSeenWelcome = false
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
        .modelContainer(for: Retrospective.self)
    }
}
