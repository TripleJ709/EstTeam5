import SwiftData
import SwiftUI

@main
struct firstProjectApp: App {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

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
