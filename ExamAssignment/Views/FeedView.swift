//
//  ContentView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//

import SwiftUI


struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    private let columns: [GridItem] = {
        #if os(iOS)
            let count = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
        #else
            let count = 2
        #endif
        return Array(repeating: GridItem(.flexible(), spacing: 5), count: count)
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 10) {
                    VideoSectionView(item: viewModel.feedItems.first)
                    
                    GridSectionView(
                        items: Array(viewModel.feedItems.dropFirst()),
                        columns: columns,
                        onLastItem: {
                            if !viewModel.isLoadingNext {
                                viewModel.loadNextData()
                            }
                        }
                    )
                    
                    if viewModel.isLoadingNext {
                        ProgressView()
                            .padding()
                    }
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
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
