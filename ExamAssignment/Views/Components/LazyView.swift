//
//  LazyView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/6/25.
//
import SwiftUI

struct LazyView<Content: View>: View {
    private let build: () -> Content
    private let id: AnyHashable
    
    init(_ build: @autoclosure @escaping () -> Content, id: AnyHashable) {
        self.build = build
        self.id = id
    }
    
    var body: some View {
        build()
            .id(id) // Đảm bảo view chỉ rebuild khi id thay đổi
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
