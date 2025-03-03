//
//  ContentView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                GeometryReader { proxy in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: proxy.frame(in: .named("scroll")).minY
                                )
                            }
                            .frame(height: 0)
                            
                VStack(spacing: 15) {
                    // Video section
                    if let firstItem = viewModel.feedItems.first, firstItem.isVideo {
                        VideoSectionView(item: firstItem)
                            .transition(.opacity)
                    }
                    
                    // Pinterest layout
                    PinterestVStack(
                        columns: calculateColumns(),
                        spacing: 10
                    ) {
                        ForEach(Array(viewModel.feedItems.dropFirst())) { item in
                            ImageCardView(url: item.url, isAd: item.isAd)
                        }
                    }
                    .padding(.horizontal)
                    
                    if viewModel.isLoadingNext {
                        ProgressView()
                            .padding()
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    scrollOffset = offset
                    // Chỉ load khi scroll gần đến cuối
                    let threshold: CGFloat = 200 // Khoảng cách từ bottom để trigger load
                    if -offset > UIScreen.main.bounds.height - threshold {
                        viewModel.checkAndLoadNextData()
                    }
                }
            .refreshable {
                await viewModel.loadPrevData()
            }
            .navigationTitle("Examination")
        }
        .onAppear {
            viewModel.loadInitialData()
        }
        .onChange(of: appViewModel.isLandscape, {
            withAnimation{
                
            }
        })
    }
    
    private func calculateColumns() -> Int {
        let device = UIDevice.current.userInterfaceIdiom
        let isLandscape = appViewModel.isLandscape
        
        switch (device, isLandscape) {
        case (.pad, true):
            return 5 // iPad landscape
        case (.pad, false):
            return 4 // iPad portrait
        case (.phone, true):
            return 3 // iPhone landscape
        default:
            return 2 // iPhone portrait
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
