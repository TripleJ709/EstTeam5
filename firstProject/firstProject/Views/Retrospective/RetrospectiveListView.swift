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
                    NavigationLink {
                        RetrospectiveDetailView(retrospective: item)
                    } label: {
                        Text("\(item.emotion.emoji) \(item.content)")
                    }
                }
            }
            .navigationTitle("회고")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        RetrospectiveWriteView()
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("회고 작성")
                    }
                }
            }
        }
    }
}

#Preview {
    RetrospectiveListView()
        .modelContainer(for: Retrospective.self, inMemory: true)
}
