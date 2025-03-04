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
                let videoHeight = isLandscape ? geometry.size.height : geometry.size.height * 0.25
                let videoSection = VideoSectionView(item: viewModel.videoItem,videoViewModel: videoViewModel).frame( height: videoHeight)
                                .id("PersistentVideoSection")
                if appViewModel.isLandscape {
                    HStack {
                        videoSection
                        createFeedGridView(columns: 2)
                    }.padding()
                    
                }else{
                    VStack{
                        videoSection
                        createFeedGridView(columns: columns())
                    }.padding()
                }
            }
            
            
        }.navigationTitle("Examination")
        .onAppear {
            viewModel.loadInitialData()
        }
    }
    
    private func createFeedGridView(columns: Int) -> some View {
            FeedGridView(
                columns: columns,
                items: Array(viewModel.feedItems),
                onLoadMore: {
                    Task {
                        await viewModel.loadNextData()
                      
                    }
                },
                onRefresh: {
                    await viewModel.loadPrevData()
                },
                onScroll: { isScrolling in
                    if isScrolling {
                        videoViewModel.pause()
                    } else {
                        videoViewModel.play()
                    }
                }
            )
            .environmentObject(viewModel)
        }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}

