//
//  VideoSectionView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//
import SwiftUI

struct VideoSectionView: View {
    let item: FeedItem?
    
    var body: some View {
        Group {
            if let item = item, item.isVideo {
                VideoView(url: item.url)
                    .frame(maxWidth: .infinity)
                    .id(item.id)
            }
        }
    }
}
