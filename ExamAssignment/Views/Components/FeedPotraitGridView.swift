//
//  FeedGridView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/4/25.
//
import SwiftUI

struct FeedPotraitGridView: View {
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
        ScrollView {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("scroll")).minY
                )
            }
            .frame(height: 0)
            
            ForEach(feedViewModel.patches) { patch in
                            VStack(spacing: 0) {
                                VideoSectionView(item: patch.video)
                                    .frame(height: videoHeight)
                                    .id("Video-\(patch.id)")
                                    .padding(.vertical)
                                
                                MasonryVStack(columns: columns, spacing: 5) {
                                    ForEach(patch.images) { item in
                                        ImageCardView(url: item.url, isAd: item.isAd)
                                            .id(item.id)
                                    }
                                }
                            }
                        }
            
            if feedViewModel.isLoadingNextData && !feedViewModel.isReachedEndOfData {
                ProgressView().padding()
            }
        }
        .refreshable {
            await onRefresh()
            videoViewModel.pause()
        }
        
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

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
