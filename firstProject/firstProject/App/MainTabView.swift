import SwiftData
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RetrospectiveListView()
                .tabItem { Label("회고", systemImage: "list.bullet") }

            StatisticsView()
                .tabItem { Label("통계", systemImage: "chart.bar") }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Retrospective.self, Category.self], inMemory: true)
}
