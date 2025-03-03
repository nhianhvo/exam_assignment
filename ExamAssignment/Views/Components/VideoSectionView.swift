//
//  VideoSectionView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//
import SwiftUI

struct VideoSectionView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    let item: FeedItem
    
    var body: some View {
        Group {
            if item.isVideo {
                VideoView(url: item.url)
                    .frame(maxWidth: .infinity)
                    .frame(height: calculateHeight())
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(radius: 2)
            }
        }
        .padding(.horizontal)
    }
    
    private func calculateHeight() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        if appViewModel.isLandscape {
            return screenHeight * 0.7 // 70% của chiều cao màn hình khi landscape
        } else {
            return screenWidth * 9/16 // Tỷ lệ 16:9 cho video
        }
    }
}
