//
//  FeedLandscapeGridView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/5/25.
//

import SwiftUI

struct FeedLandscapeGridView: View {
    let columns: Int
    let onLoadMore: () -> Void
    let onRefresh: () async -> Void
    let onScroll: (Bool) -> Void
    let videoHeight: CGFloat?
    
    @State private var scrollOffset: CGFloat = 0
    @EnvironmentObject private var feedViewModel: FeedViewModel
    @StateObject private var videoViewModel: VideoViewModel = .shared
    @State private var isScrolling = false
    
    var body: some View {
        HStack(spacing: 0) {
            VideoSectionView(item: feedViewModel.videoItem,videoViewModel: videoViewModel,feedViewModel: feedViewModel)
                .frame(height: videoHeight)
                .id("Video-\(feedViewModel.videoItem?.id ?? 0)")
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0))
            ScrollView {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollOffsetLandscapePreferenceKey.self,
                        value: proxy.frame(in: .named("scroll")).minY
                    )
                }
                .frame(height: 0)
                
                MasonryVStack(columns: columns, spacing: 5) {
                    ForEach(feedViewModel.feedItems) { item in
                        ImageCardView(url: item.url, isAd: item.isAd)
                            .id(item.id)
                    }
                }
                
                if feedViewModel.isLoadingNextData && !feedViewModel.isReachedEndOfData {
                    ProgressView().padding()
                }
            }.padding(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 0))
            .refreshable {
                await onRefresh()
                videoViewModel.pause()
            }
        }.padding()
        
        
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            let oldOffset = scrollOffset
            scrollOffset = offset
            
            let isCurrentlyScrolling = abs(oldOffset - offset) > 1
            
            if isCurrentlyScrolling != isScrolling {
                isScrolling = isCurrentlyScrolling
                onScroll(isCurrentlyScrolling)
            }
            
            let threshold: CGFloat = 200
            if -offset > UIScreen.main.bounds.height - threshold && !feedViewModel.isLoadingNextData {
                onLoadMore()
            }
        }
    }
}

struct ScrollOffsetLandscapePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
