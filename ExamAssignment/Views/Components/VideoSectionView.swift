//
//  VideoSectionView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//
import SwiftUI

struct VideoSectionView: View {
    let item: FeedItem?
    @ObservedObject var videoViewModel: VideoViewModel
    @ObservedObject var feedViewModel: FeedViewModel
    var body: some View {
        Group {
            if let item = item, item.isVideo {
                VideoView(url: item.url, id: item.id, viewModel: videoViewModel)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .onAppear {
                                    videoViewModel.setupPlayer(with: item.url)
                        feedViewModel.setCurrentPlaying(item.id)
                                }
                                .onDisappear {
                                    videoViewModel.cleanup()
                                }
                                .onChange(of: feedViewModel.currentPlayingId) { oldId, newId in
                                    if newId == item.id {
                                        videoViewModel.play()
                                    } else {
                                        videoViewModel.pause()
                                    }
                                }
                    
            }
        }
    }
}
