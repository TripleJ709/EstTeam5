//
//  RetrospectiveWriteView.swift
//  firstProject
//
//  Created by 임사랑 on 11/17/26.
//

import SwiftUI

struct RetrospectiveWriteView: View {
    var body: some View {
        Text("회고 작성")
            .foregroundStyle(.secondary)
            .navigationTitle("회고 작성")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RetrospectiveWriteView()
    }
}
