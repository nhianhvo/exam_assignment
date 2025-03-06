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
    let spacing: CGFloat = 5
    
    func getTriggerZone(for index: Int) -> (start: CGFloat, end: CGFloat) {
        switch index {
        case 0:
            return (CGFloat(0), CGFloat(-200))
        case 1:
            return (CGFloat(-1550), CGFloat(-2350))
        case 2:
            return (CGFloat(-3500), CGFloat(-4300))
        default:
            let start = CGFloat(-3500 - (index - 2) * 800)
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
                        VStack(spacing: 0) {
                            VideoSectionView(item: patch.video,videoViewModel: feedViewModel.videoViewModels[index],feedViewModel: feedViewModel)
                                .frame(height: videoHeight)
                                .id("Video-\(patch.id)")
                                .padding(.vertical)
                                .background(GeometryReader { geometry in
                                    Color.clear.onAppear {
                                        videoFrames["Video-\(patch.id)"] =
                                        geometry.frame(in: .global)
                                    }
                                })
                            
                            MasonryVStack(columns: Int(columns), spacing: spacing) {
                                ForEach(patch.images) { item in
                                    ImageCardView(url: item.url, isAd: item.isAd, preferWidth: CGFloat(item.width ?? 0), preferHeight: CGFloat(item.height ?? 0), targetWidth: CGFloat((geometry.size.width - (columns-1)*spacing)/columns))
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
                //            .onChange(of: scrollOffset) { oldValue, newValue in
                //                print("\n📜 Scroll Offset:", newValue)
                //                let scrollDirection = newValue - oldValue
                ////                print("↕️ Scroll Direction:", scrollDirection)
                //
                //                if let currentIndex = getCurrentIndex(from: newValue) {
                //                        self.currentVideoIndex = currentIndex
                //                        print("📍 Current Index:", currentIndex)
                //                        let patch = feedViewModel.patches[currentIndex]
                //                        feedViewModel.setCurrentPlaying(patch.video.id)
                //
                //                        let zone = getTriggerZone(for: currentIndex)
                //                        print("🎯 Current zone:", zone.start, "to", zone.end)
                //                    print("isDragging: \(isDragging)")
                //                        if newValue < zone.start && newValue > zone.end && !isDragging {
                //                            print("Co vo day khong")
                //                            let currentTime = Date()
                //                            let timeSinceLastScroll = currentTime.timeIntervalSince(lastScrollTime)
                //
                //                            if timeSinceLastScroll > 0.03 && !isAutoScrolling {
                //                                print("\n✨ TRIGGER AUTO SCROLL")
                //                                isAutoScrolling = true
                //
                //                                print("IN target Index: \(currentIndex)")
                //                                let targetPatch = feedViewModel.patches[currentIndex]
                //                                print("🎬 Scrolling to Video-\(targetPatch.id)")
                //
                //                                withAnimation(.easeOut(duration: 0.3)) {
                //                                    scrollProxy.scrollTo("Video-\(targetPatch.id)", anchor: .top)
                //                                }
                //
                //
                //                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                //                                    checkPlayOrPauseVideo(currentIndex: currentIndex)
                //                                    isAutoScrolling = false
                //                                }
                //                            }
                //                        }
                //                }
                //
                //
                //
                //                lastScrollTime = Date()
                //            }
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    //                let oldOffset = scrollOffset
                    //                scrollOffset = offset
                    //
                    //                let isCurrentlyScrolling = abs(oldOffset - offset) > 1
                    //
                    //                if isCurrentlyScrolling != isScrolling {
                    //                    isScrolling = isCurrentlyScrolling
                    //                    if !isScrolling {
                    //                        print("playing: \(currentVideoIndex)")
                    //                        checkPlayOrPauseVideo(currentIndex: currentVideoIndex)
                    //                    }else{
                    //                        feedViewModel.videoViewModels.forEach { $0.pause() }
                    //                    }
                    //                }
                    //
                    //                let threshold: CGFloat = 200
                    //                if -offset > UIScreen.main.bounds.height - threshold && !feedViewModel.isLoadingNextData {
                    //                    onLoadMore()
                    //                }
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
