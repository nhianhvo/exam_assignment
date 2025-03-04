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
    @Published var videoItem: FeedItem?
    
    func loadInitialData() {
        let data = FeedRepository.fetchData()
        var items: [FeedItem] = []
        videoItem = FeedItem(id: 0, url: data.video, isVideo: true, isAd: false)
        items.append(contentsOf: data.images.map {
            FeedItem(id: $0.id, url: $0.url, isVideo: false, isAd: false)
        })
        feedItems = mixAdvToFeedItems(items: items)
    }
    
    func loadNextData() {
        if let fromIndex = feedItems.last?.id, let data = FeedRepository.fetchNewData(fromIndex: fromIndex){
            videoItem = FeedItem(id: 0, url: data.video, isVideo: true, isAd: false)
            let newItems = data.images.map {
                FeedItem(id: $0.id, url: $0.url, isVideo: false, isAd: false)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.feedItems.append(contentsOf: self.mixAdvToFeedItems(items: newItems))
            }
        }else{
            //Has no new data
            return
        }
    }
    
    func loadPrevData() async {
        if let fromIndex = feedItems.first?.id, let data = FeedRepository.fetchOldData(fromIndex: fromIndex){
            videoItem = FeedItem(id: 0, url: data.video, isVideo: true, isAd: false)
            let newItems = data.images.map {
                FeedItem(id: $0.id, url: $0.url, isVideo: false, isAd: false)
            }
            feedItems.insert(contentsOf: mixAdvToFeedItems(items: newItems), at: 0)
        }else{
            //Has no old data
            return
        }
    }
    
    func mixAdvToFeedItems(items: [FeedItem]) -> [FeedItem]{
        var result = items
        if let advData = AdvRepository.fetchAdvData(){
            let fibonacciIndices = Utils.getFibonacciArray(count: items.count)
            for index in fibonacciIndices where index < items.count {
                if let ad = advData.ads.randomElement() {
                    result.insert(FeedItem(id: ad.id, url: ad.url, isVideo: false, isAd: true), at: index)
                }
            }
        }
        return result
    }
}
