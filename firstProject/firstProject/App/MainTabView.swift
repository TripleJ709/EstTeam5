import SwiftData
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RetrospectiveListView()
                .tabItem { Label("달력", systemImage: "calendar") }

            StatisticsView()
                .tabItem { Label("기록", systemImage: "chart.bar") }
        }
        .tint(Color.tintPrimary)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Retrospective.self, inMemory: true)
}
