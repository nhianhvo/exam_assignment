//
//  VideoSectionView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//
import SwiftUI

struct VideoSectionView: View {
    let item: FeedItem?
    let videoViewModel: VideoViewModel
    var body: some View {
        Group {
            if let item = item, item.isVideo {
                VideoView(url: item.url,viewModel: videoViewModel)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .id("VideoSection-\(item.id)-\(item.url)")
            }
        }
    }
}
