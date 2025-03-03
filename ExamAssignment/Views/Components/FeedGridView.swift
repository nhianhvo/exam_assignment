//
//  FeedGridView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/4/25.
//
import SwiftUI

struct FeedGridView: View {
    let columns: Int
    let items: [FeedItem]
    let onLoadMore: () -> Void
    let onRefresh: () async -> Void
    
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("scroll")).minY
                )
            }
            .frame(height: 0)
            
            MasonryVStack(columns: columns, spacing: 5) {
                ForEach(items) { item in
                    ImageCardView(url: item.url, isAd: item.isAd).id(item.id)
                }
            }
        }
        .refreshable {
            await onRefresh()
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            scrollOffset = offset
            let threshold: CGFloat = 200
            if -offset > UIScreen.main.bounds.height - threshold {
                onLoadMore()
            }
        }
    }
}
