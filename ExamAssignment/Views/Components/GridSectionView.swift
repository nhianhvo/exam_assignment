//
//  GridSectionView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//
import SwiftUI

struct GridSectionView: View {
    let items: [FeedItem]
    let columns: [GridItem]
    let onLastItem: () -> Void
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 5) {
            ForEach(items) { item in
                ImageCardView(url: item.url, isAd: item.isAd)
                    .onAppear {
                        if item.id == items.last?.id {
                            onLastItem()
                        }
                    }
            }
        }
        .padding(.horizontal)
    }
}
