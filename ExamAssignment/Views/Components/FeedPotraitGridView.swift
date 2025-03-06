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
    let videoHeight: CGFloat?
    
    @State private var scrollOffset: CGFloat = 0
    @EnvironmentObject private var feedViewModel: FeedViewModel
    @StateObject private var videoViewModel: VideoViewModel = .shared
    @State private var isScrolling = false
    @State private var videoFrames: [String: CGRect] = [:]
    
    var body: some View {
        ScrollViewReaderContent(
            scrollOffset: $scrollOffset,
            videoFrames: $videoFrames,
            videoHeight: videoHeight,
            feedViewModel: feedViewModel,
            columns: CGFloat(columns),
            onLoadMore: onLoadMore,
            onRefresh: onRefresh
        )
    }
    
}

private struct ScrollViewReaderContent: View {
    @Binding var scrollOffset: CGFloat
    @Binding var videoFrames: [String: CGRect]
    let videoHeight: CGFloat?
    @ObservedObject var feedViewModel: FeedViewModel
    @StateObject private var videoViewModel: VideoViewModel = .shared
    let columns: CGFloat
    let onLoadMore: () -> Void
    let onRefresh: () async -> Void
    @State private var isScrolling = false
    @State private var isAutoScrolling = false
    @State private var lastScrollTime = Date()
    @State private var isDragging = false
    @State private var currentVideoIndex: Int = 0
    @State private var timer: Timer?
    @State private var lastOffset: CGFloat = 0
    let spacing: CGFloat = 5
    
    func getTriggerZone(for index: Int) -> (start: CGFloat, end: CGFloat) {
        switch index {
        case 0:
            return (CGFloat(0), CGFloat(-200))
        case 1:
            return (CGFloat(-1550), CGFloat(-2350))
        case 2:
            return (CGFloat(-3900), CGFloat(-4300))
        default:
            let start = CGFloat(-4000 - (index - 2) * 800)
            let end = CGFloat(start - 800)
            return (start, end)
        }
    }
    
    func getCurrentIndex(from scrollOffset: CGFloat) -> Int? {
        for index in 0..<feedViewModel.patches.count {
            let zone = getTriggerZone(for: index)
            if scrollOffset < zone.start && scrollOffset > zone.end {
                return index
            }
        }
        return nil
    }
    
    @State private var scrolling = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("scroll")).minY
                        )
                    }
                    .frame(height: 0)
                    ForEach(Array(feedViewModel.patches.enumerated()), id: \.element.id) { index, patch in
                        VStack(spacing: spacing) {
                            VideoSectionView(item: patch.video,videoViewModel: feedViewModel.videoViewModels[index],feedViewModel: feedViewModel)
                                .frame(height: geometry.size.height*0.25)
                                .id("Video-\(patch.id)")
                                .background(GeometryReader { geometry in
                                    Color.clear.onAppear {
                                        videoFrames["Video-\(patch.id)"] =
                                        geometry.frame(in: .global)
                                    }
                                })
                            MasonryVStack(columns: Int(columns), spacing: spacing) {
                                ForEach(patch.images) { item in
                                    ImageCardView(url: item.url, isAd: item.isAd, preferWidth: CGFloat(item.width ?? 0), preferHeight: CGFloat(item.height ?? 0), targetWidth: CGFloat((geometry.size.width - (columns-1)*spacing)/columns), priceTags: item.price_tags )
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
                    feedViewModel.videoViewModels[currentVideoIndex].pause()
                }.simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            isDragging = true
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { _ in
                            isDragging = true
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
                .coordinateSpace(name: "scroll")
                .onChange(of: scrollOffset) { oldValue, newValue in
                    if let currentIndex = getCurrentIndex(from: newValue) {
                        self.currentVideoIndex = currentIndex
                        let patch = feedViewModel.patches[currentIndex]
                        feedViewModel.setCurrentPlaying(patch.video.id)
                        
                        let zone = getTriggerZone(for: currentIndex)
                        if newValue < zone.start && newValue > zone.end && !isDragging {
                            let currentTime = Date()
                            let timeSinceLastScroll = currentTime.timeIntervalSince(lastScrollTime)
                            
                            if timeSinceLastScroll > 0.03 && !isAutoScrolling {
                                isAutoScrolling = true
                                let targetPatch = feedViewModel.patches[currentIndex]
                                
                                withAnimation(.easeOut(duration: 0.3)) {
                                    scrollProxy.scrollTo("Video-\(targetPatch.id)", anchor: .top)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    checkPlayOrPauseVideo(currentIndex: currentIndex)
                                    isAutoScrolling = false
                                }
                            }
                        }
                    }
                    lastScrollTime = Date()
                }
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    isScrolling = true
                    scrollOffset = offset
                    timer?.invalidate() // Reset timer
                    feedViewModel.videoViewModels.forEach { $0.pause() }
                    // Delay detection to check if scrolling stops
                    timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                        if abs(offset - lastOffset) < 1 {
                            print("Scrolling stopped (didEndDecelerating)")
                            isScrolling = false
                            checkPlayOrPauseVideo(currentIndex: currentVideoIndex)
                        }
                        lastOffset = offset
                    }
                    
                    let threshold: CGFloat = 200
                    if -offset > UIScreen.main.bounds.height - threshold && !feedViewModel.isLoadingNextData {
                        onLoadMore()
                    }
                }
            }
        }
    }
    
    
    private func checkPlayOrPauseVideo(currentIndex: Int){
        for (index, videoViewModel) in feedViewModel.videoViewModels.enumerated() {
            if index == currentIndex {
                videoViewModel.play()
                print("▶️ Playing video at index", index)
            } else {
                videoViewModel.pause()
                print("⏸️ Paused video at index", index)
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

