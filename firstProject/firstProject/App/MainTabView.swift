import SwiftData
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RetrospectiveListView()
                .tabItem { Label("회고", systemImage: "calendar") }

            StatisticsView()
                .tabItem { Label("통계", systemImage: "chart.bar") }
        }
        .tint(Color.tintPrimary)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Retrospective.self, inMemory: true)
}
