import SwiftData
import SwiftUI

struct RetrospectiveListView: View {
    @Query(sort: \Retrospective.date, order: .reverse)
    private var retrospectives: [Retrospective]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CalendarView()
                List(retrospectives) { item in
                    Text("\(item.emotion.emoji) \(item.content)")
                }
            }
            .navigationTitle("회고")
        }
    }
}

#Preview {
    RetrospectiveListView()
        .modelContainer(for: [Retrospective.self, Category.self], inMemory: true)
}
