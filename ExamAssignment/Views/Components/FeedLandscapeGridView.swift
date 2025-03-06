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
    @State private var isScrolling = false
    @State private var timer: Timer?
    @State private var lastOffset: CGFloat = 0
    @State private var lastLoadMoreTime: Date = Date(timeIntervalSince1970: 0)
    @State private var currentVideoIndex: Int = 0
    
    @State private var itemHeights: [Int: CGFloat] = [:]
    @State private var zoneBreakpoints: [Int] = []
    
    var body: some View {
        HStack(spacing: 0) {
            if !feedViewModel.patches.isEmpty && currentVideoIndex < feedViewModel.patches.count {
                VideoSectionView(
                    item: feedViewModel.patches[currentVideoIndex].video,
                    videoViewModel: feedViewModel.videoViewModels[currentVideoIndex],
                    feedViewModel: feedViewModel
                )
                .frame(height: videoHeight)
                .id("Video-\(feedViewModel.patches[currentVideoIndex].id)")
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: videoHeight)
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            }
            ScrollView {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: proxy.frame(in: .named("scroll")).minY
                    )
                }
                .frame(height: 0)
                
                MasonryVStack(columns: columns, spacing: 5) {
                    ForEach(Array(feedViewModel.feedItems.enumerated()), id: \.element.id) { index, item in
                        ImageCardView(
                            url: item.url,
                            isAd: item.isAd,
                            preferWidth: CGFloat(item.width ?? 0),
                            preferHeight: CGFloat(item.height ?? 0),
                            targetWidth: 0,
                            priceTags: item.price_tags
                        )
                        .id(item.id)
                        .background(
                            GeometryReader { geo in
                                Color.clear.onAppear {
                                    // Lưu chiều cao của item
                                    itemHeights[index] = geo.size.height
                                    calculateZoneBreakpoints()
                                }
                            }
                        )
                    }
                }
                
                if feedViewModel.isLoadingNextData && !feedViewModel.isReachedEndOfData {
                    ProgressView().padding()
                }
            }.padding(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 0))
                .refreshable {
                    await onRefresh()
                }.simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            feedViewModel.videoViewModels[currentVideoIndex].pause()
                        }
                        .onEnded { _ in
                            feedViewModel.videoViewModels[currentVideoIndex].play()
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { _ in
                            feedViewModel.videoViewModels[currentVideoIndex].pause()
                        }
                        .onEnded { _ in
                            feedViewModel.videoViewModels[currentVideoIndex].play()
                        }
                )
        }.padding()
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                isScrolling = true
                scrollOffset = offset
                timer?.invalidate()
                
                timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                    if abs(offset - lastOffset) < 1 {
                        print("Scrolling stopped (didEndDecelerating)")
                        isScrolling = false
                    }
                    lastOffset = offset
                }
                
                updateCurrentVideoIndex(for: offset)
                
                let screenHeight = UIScreen.main.bounds.height
                
                let threshold: CGFloat = screenHeight * 0.4
                let now = Date()
                let timeSinceLastLoad = now.timeIntervalSince(lastLoadMoreTime)
                
                if -offset > UIScreen.main.bounds.height - threshold &&
                        !feedViewModel.isLoadingNextData &&
                        !feedViewModel.isReachedEndOfData &&
                        timeSinceLastLoad > 2.0 {
                    
                    print("Calling loadNextData() at offset: \(offset)")
                    lastLoadMoreTime = now
                    onLoadMore()
                }
            }
    }
    
    private func calculateZoneBreakpoints() {
        let totalVideoModels = feedViewModel.videoViewModels.count
        guard totalVideoModels > 0 else { return }
        
        let totalItems = feedViewModel.feedItems.count
        
        let itemsPerZone = max(1, totalItems / totalVideoModels)
        
        // Tính các breakpoints
        var breakpoints: [Int] = []
        var currentHeight: CGFloat = 0
        var itemsInCurrentZone = 0
        
        for i in 0..<totalItems {
            if let height = itemHeights[i] {
                currentHeight += height + 5
                itemsInCurrentZone += 1
                
                if itemsInCurrentZone >= itemsPerZone {
                    breakpoints.append(Int(currentHeight))
                    itemsInCurrentZone = 0
                }
            }
        }
        
        zoneBreakpoints = breakpoints
    }
    
    private func updateCurrentVideoIndex(for offset: CGFloat) {
        let absoluteOffset = abs(offset)
        
        var newIndex = 0
        for (i, breakpoint) in zoneBreakpoints.enumerated() {
            if absoluteOffset < CGFloat(breakpoint) {
                newIndex = i
                break
            } else {
                newIndex = i + 1
            }
        }
        
        let totalVideoModels = feedViewModel.videoViewModels.count
        newIndex = min(newIndex, totalVideoModels - 1)
        
        if newIndex != currentVideoIndex && newIndex >= 0 {
            print("Switching video from index \(currentVideoIndex) to \(newIndex)")
            currentVideoIndex = newIndex
        }
    }
}
