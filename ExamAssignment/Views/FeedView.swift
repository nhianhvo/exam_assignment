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
            if appViewModel.isLandscape {
                HStack {
                    VideoSectionView(item: viewModel.videoItem).frame( height: .infinity)
                        
                    FeedGridView(
                        columns: 2,
                        items: Array(viewModel.feedItems.dropFirst()),
                        onLoadMore: {
                            Task {
                                 viewModel.loadNextData()
                            }
                        },
                        onRefresh: {
                            await viewModel.loadPrevData()
                        }
                    )
                }.padding()
                
            }else{
                VStack{
                    VideoSectionView(item: viewModel.videoItem).frame(height: columns() == 2 ? 200 : 300)
                        
                    FeedGridView(
                        columns: columns(),
                        items: Array(viewModel.feedItems.dropFirst()),
                        onLoadMore: {
                            Task {
                                 viewModel.loadNextData()
                            }
                        },
                        onRefresh: {
                            await viewModel.loadPrevData()
                        }
                    )
                }.padding()
            }
        }.navigationTitle("Examination")
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

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
