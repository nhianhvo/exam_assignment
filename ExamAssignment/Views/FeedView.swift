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
            VStack{
                VideoSectionView(item: viewModel.videoItem)
                ScrollView {
                    MasonryVStack(columns: 2, spacing: 5) {
                        ForEach(viewModel.feedItems.dropFirst()) { item in
                            ImageCardView(url: item.url, isAd: item.isAd)
                                .onAppear {
                                   
                                }
                        }
                        
                    }
                    
                }.refreshable {
                    await viewModel.loadPrevData()
                }
            }.padding()
            
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
