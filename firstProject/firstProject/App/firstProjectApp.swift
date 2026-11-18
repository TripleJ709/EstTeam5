import SwiftData
import SwiftUI

@main
struct firstProjectApp: App {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenWelcome {
                    MainTabView()
                } else {
                    WelcomeView { hasSeenWelcome = true }
                }
            }
            .preferredColorScheme(appTheme.colorScheme)
        }
        .modelContainer(for: Retrospective.self)
    }
}
