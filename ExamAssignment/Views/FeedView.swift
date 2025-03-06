//
//  ContentView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//

import SwiftUI


struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var scrollOffset: CGFloat = 0
    @EnvironmentObject private var appViewModel: AppViewModel
    let videoViewModel = VideoViewModel()
    
    private func columns() -> Int{
        let device = UIDevice.current.userInterfaceIdiom
        if device == .phone {
            return 2
        } else {
            return 3
        }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                let videoHeight = isLandscape ? geometry.size.height * 0.92 : geometry.size.height * 0.25
                if appViewModel.isLandscape {
                    LazyView(FeedLandscapeGridView(columns: 2, onLoadMore: {
                        Task {
                            await viewModel.loadNextData()
                            
                        }
                    }, onRefresh: {
                        await viewModel.loadPrevData()
                    }, onScroll: { isScrolling in
                        if isScrolling {
                            videoViewModel.pause()
                        } else {
                            videoViewModel.play()
                        }
                    }, videoHeight: videoHeight), id: "landscape")
                }else{
                    LazyView(
                        FeedPotraitGridView(
                            columns: columns(),
                            onLoadMore: {
                                Task {
                                    await viewModel.loadNextData()
                                }
                            },
                            onRefresh: {
                                await viewModel.loadPrevData()
                            },
                            videoHeight: videoHeight
                        ).padding(),
                        id: "potrait")
                }
            }
            
            
        }.navigationTitle("Examination")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.keyboard)
            .environmentObject(viewModel)
            .onAppear {
                viewModel.loadInitialData()
            }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}

