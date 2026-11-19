import SwiftData
import SwiftUI

/// 앱의 메인 화면입니다. 회고(달력) 탭과 통계(기록) 탭으로 이루어져 있습니다.
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
