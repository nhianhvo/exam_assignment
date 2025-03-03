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
    
    private var hasReachedEnd = false
    
    func checkAndLoadNextData() {
            guard !hasReachedEnd else { return }
            
            loadNextData()
        }
    
    func loadInitialData() {
        print("loadInitialData")
        let data: FeedData = DataLoader.loadJSON("current")
        let adData: AdData = DataLoader.loadJSON("adv")
        
        var items: [FeedItem] = []
        items.append(FeedItem(id: UUID().uuidString, url: data.video, isVideo: true, isAd: false, price: nil, tagPosition: nil))
        
        items.append(contentsOf: data.images.map {
            FeedItem(id: "\($0.id)", url: $0.url, isVideo: false, isAd: false,price: $0.price, tagPosition: $0.tagPosition.map{ FeedItem.TagPosition(x: $0.x, y: $0.y) })
        })
        
        let fibonacciIndices = [1, 2, 3, 5, 8, 13, 21]
        for index in fibonacciIndices where index < items.count {
            if let ad = adData.ads.randomElement() {
                items.insert(FeedItem(id: ad.id, url: ad.url, isVideo: false, isAd: true), at: index + 1)
            }
        }
        
        feedItems = items
    }
    
    func loadNextData() {
        guard !isLoadingNext else { return }
        isLoadingNext = true
        print("loadNextData")
        let data: FeedData = DataLoader.loadJSON("next")
        let newItems = data.images.map {
            FeedItem(id: "\($0.id)", url: $0.url, isVideo: false, isAd: false, price: $0.price, tagPosition: $0.tagPosition.map{ FeedItem.TagPosition(x: $0.x, y: $0.y) })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.feedItems.append(contentsOf: newItems)
            self.isLoadingNext = false
            self.hasReachedEnd = true
        }
    }
    
    @MainActor
    func loadPrevData() async {
        print("loadPrevData")
        isRefreshing = true
        let data: FeedData = DataLoader.loadJSON("prev")
        let newItems = data.images.map {
            FeedItem(id: "\($0.id)", url: $0.url, isVideo: false, isAd: false, price: $0.price, tagPosition: $0.tagPosition.map{ FeedItem.TagPosition(x: $0.x, y: $0.y) })
        }
        feedItems.insert(contentsOf: newItems, at: 1)
        isRefreshing = false
    }
}
