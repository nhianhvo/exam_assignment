//
//  FeedViewModel.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//

import Foundation
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoadingNext = false
    @Published var isRefreshing = false
    
    func loadInitialData() {
        let data: FeedData = DataLoader.loadJSON("current")
        let adData: AdData = DataLoader.loadJSON("adv")
        
        var items: [FeedItem] = []
        items.append(FeedItem(id: UUID().uuidString, url: data.video, isVideo: true, isAd: false))
        
        items.append(contentsOf: data.images.map {
            FeedItem(id: "\($0.id)", url: $0.url, isVideo: false, isAd: false)
        })
        
        let fibonacciIndices = [1, 2, 3, 5, 8, 13, 21]
        for index in fibonacciIndices where index < items.count {
            if let ad = adData.ads.randomElement() {
                items.insert(FeedItem(id: ad.id, url: ad.url, isVideo: false, isAd: true), at: index)
            }
        }
        
        feedItems = items
    }
    
    func loadNextData() {
        isLoadingNext = true
        let data: FeedData = DataLoader.loadJSON("next")
        let newItems = data.images.map {
            FeedItem(id: "\($0.id)", url: $0.url, isVideo: false, isAd: false)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.feedItems.append(contentsOf: newItems)
            self.isLoadingNext = false
        }
    }
    
    @MainActor
    func loadPrevData() async {
        isRefreshing = true
        let data: FeedData = DataLoader.loadJSON("prev")
        let newItems = data.images.map {
            FeedItem(id: "\($0.id)", url: $0.url, isVideo: false, isAd: false)
        }
        feedItems.insert(contentsOf: newItems, at: 1)
        isRefreshing = false
    }
}
