//
//  RetrospectiveDetailView.swift
//  firstProject
//
//  Created by 임사랑 on 11/17/26.
//

import SwiftData
import SwiftUI

struct RetrospectiveDetailView: View {
    let retrospective: Retrospective

    var body: some View {
        Text("회고 상세")
            .foregroundStyle(.secondary)
            .navigationTitle("회고 상세")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RetrospectiveDetailView(
            retrospective: Retrospective(content: "테스트 회고", emotion: .joy)
        )
    }
    .modelContainer(for: Retrospective.self, inMemory: true)
}
