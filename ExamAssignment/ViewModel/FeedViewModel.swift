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
    
    @Published var isLoadingNextData: Bool = false
    @Published var isReachedEndOfData: Bool = false
    @Published var patches: [Patch] = []
    @Published var videoViewModels: [VideoViewModel] = [VideoViewModel()]
    private let itemsPerPatch = 20
    @Published var currentPatchIndex: Int = 0
    @Published var currentPlayingId: Int?
    
    func setCurrentPlaying(_ id: Int) {
        currentPlayingId = id
    }
    
    private func setupVideoViewModels(isPrevData: Bool = false) {
            print("📱 Setting up VideoViewModels")
            print("   Patches count:", patches.count)
            print("   Current ViewModels:", videoViewModels.count)
            
            while videoViewModels.count < patches.count {
                if(isPrevData){
                    videoViewModels.insert(VideoViewModel(),at: 0)
                }else{
                    videoViewModels.append(VideoViewModel())
                }
                print("   Added new ViewModel")
            }
            
            if videoViewModels.count > patches.count {
                videoViewModels = Array(videoViewModels.prefix(patches.count))
                print("   Trimmed ViewModels to", videoViewModels.count)
            }
        }
    
    private func organizeIntoPatch(_ items: [FeedItem], isPrevData: Bool = false) {
            var currentPatchId = patches.count + 1
            var currentIndex = 0
            
            while currentIndex < items.count {
                if let video = items[currentIndex...].first(where: { $0.isVideo }) {
                    let nextVideoIndex = items[(currentIndex + 1)...].firstIndex(where: { $0.isVideo }) ?? items.count
                    let patchImages = Array(items[(currentIndex + 1)..<nextVideoIndex])
                    
                    if(patches.contains(where: {$0.video.url == video.url})){
                        return
                    }
                    if(isPrevData){
                        let newPatch = Patch(id: 0, video: video, images: self.mixAdvToFeedItems(items: patchImages))

                        patches.insert(newPatch, at: 0)
                    }else{
                        let newPatch = Patch(id: currentPatchId, video: video, images: self.mixAdvToFeedItems(items: patchImages))

                        patches.append(newPatch)
                    }
                    
                    currentPatchId += 1
                    currentIndex = patchImages.count - 1 
                } else {
                    break
                }
                print("patch count: \(patches.count)")
            }
        }
    
    func loadInitialData() {
        let data = FeedRepository.fetchData()
        var items: [FeedItem] = []
        videoItem = FeedItem(id: 0, url: data.video, isVideo: true, isAd: false, width: 0, height: 0, price_tags: nil)
        items.append(FeedItem(id: 0, url: data.video, isVideo: true, isAd: false, width: 0, height: 0, price_tags: nil))
        let images = data.images.map {
            FeedItem(id: $0.id, url: $0.url, isVideo: false, isAd: false, width: $0.width, height: $0.height, price_tags: $0.price_tags)
        }
        items.append(contentsOf: images)
        feedItems = mixAdvToFeedItems(items: images)
        self.organizeIntoPatch(items)
    }
    
    func loadNextData() async {
        guard !isLoadingNextData else {
            print("Still loading, skipping...")
            return
        }
       
        guard let lastPatch = patches.last else {
                await MainActor.run {
                    self.isLoadingNextData = false
                    self.isReachedEndOfData = true
                }
                return
            }
        
        let lastItemId = lastPatch.images.last?.id ?? lastPatch.video.id
        
        if let data = FeedRepository.fetchNewData(fromIndex: lastItemId){
            let videoItem = FeedItem(id: lastItemId + 1, url: data.video,isVideo: true, isAd: false, width: 0, height: 0, price_tags: nil)
            let imagesItem = data.images.map {
                FeedItem(id: $0.id, url:  $0.url, isVideo: false, isAd: false, width: $0.width, height: $0.height, price_tags: $0.price_tags)
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                var newItems: [FeedItem] = []
                newItems.append(videoItem)
                newItems.append(contentsOf: imagesItem)
                self.videoItem = videoItem
                self.feedItems.append(contentsOf: self.mixAdvToFeedItems(items: imagesItem))
                self.organizeIntoPatch(newItems)
                self.setupVideoViewModels()
                self.isLoadingNextData = false
            }
        }
        else{
            //Has no new data
            await MainActor.run {
                self.isLoadingNextData = false
                self.isReachedEndOfData = true
            }
            return
        }
    }
    
    func loadPrevData() async {
        guard let firstPatch = patches.first else {
                await MainActor.run {
                    self.isLoadingNextData = false
                    self.isReachedEndOfData = true
                }
                return
            }
        
        if let fromIndex = firstPatch.images.first?.id, let data = FeedRepository.fetchOldData(fromIndex: fromIndex){
            let videoItems = FeedItem(id: 0, url: data.video, isVideo: true, isAd: false, width: 0, height: 0, price_tags: nil)
            let newItems = data.images.map {
                FeedItem(id: $0.id, url: $0.url, isVideo: false, isAd: false, width: $0.width, height: $0.height, price_tags: $0.price_tags)
            }
            
            let newFeedItems: [FeedItem] = [videoItems] + newItems
            await MainActor.run {
                videoItem = videoItems
                feedItems.insert(contentsOf: mixAdvToFeedItems(items: newItems), at: 0)
                organizeIntoPatch(newFeedItems, isPrevData: true)
                self.setupVideoViewModels(isPrevData: true)
            }
            
          
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
                    result.insert(FeedItem(id: ad.id, url: ad.url, isVideo: false, isAd: true, width: ad.width, height:ad.height, price_tags: nil), at: index)
                }
            }
        }
        return result
    }
}
