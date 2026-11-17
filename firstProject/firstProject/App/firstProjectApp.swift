import SwiftData
import SwiftUI

@main
struct firstProjectApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Retrospective.self)
    }
}
