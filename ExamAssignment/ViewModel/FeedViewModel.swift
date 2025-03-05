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
    private let itemsPerPatch = 20
    @Published var currentPatchIndex: Int = 0
    
    private func organizeIntoPatch(_ items: [FeedItem], isPrevData: Bool = false) {
            var currentPatchId = patches.count
            var currentIndex = 0
            
            while currentIndex < items.count {
                if let video = items[currentIndex...].first(where: { $0.isVideo }) {
                    let nextVideoIndex = items[(currentIndex + 1)...].firstIndex(where: { $0.isVideo }) ?? items.count
                    let patchImages = Array(items[(currentIndex + 1)..<nextVideoIndex])
                    
                    let newPatch = Patch(id: currentPatchId, video: video, images: self.mixAdvToFeedItems(items: patchImages))
                    if(patches.contains(where: {$0.video.url == video.url})){
                        return
                    }
                    if(isPrevData){
                        patches.insert(newPatch, at: 0)
                    }else{
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
        videoItem = FeedItem(id: 0, url: data.video, isVideo: true, isAd: false)
        items.append(FeedItem(id: 0, url: data.video, isVideo: true, isAd: false))
        let images = data.images.map {
            FeedItem(id: $0.id, url: $0.url, isVideo: false, isAd: false)
        }
        items.append(contentsOf: images)
        feedItems = mixAdvToFeedItems(items: images)
        self.organizeIntoPatch(items)
        
//        // Loop through the URLs and fetch dimensions
//        for url in imageUrls {
//            fetchImageSize(from: url)
//        }
    }
    
    func loadNextData() async {
        guard !isLoadingNextData else {
            print("Still loading, skipping...")
            return
        }
       
//        await MainActor.run { isLoadingNextData = true }
//       
//        if let fromIndex = feedItems.last?.id, let data = FeedRepository.fetchNewData(fromIndex: fromIndex){
//            
//            let newItems = data.images.map {
//                FeedItem(id: $0.id, url: $0.url, isVideo: false, isAd: false)
//            }
//
//            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
//                        
//                await MainActor.run {
////                    self.videoItem = FeedItem(id: 0, url: data.video, isVideo: true, isAd: false)
//                    
//                    self.feedItems.append(FeedItem(id: 0, url: data.video, isVideo: true, isAd: false))
//                    self.feedItems.append(contentsOf: self.mixAdvToFeedItems(items: newItems))
//                    
//                    organizeIntoPatch(mixAdvToFeedItems(items: newItems))
//                    self.isLoadingNextData = false
//                }
//        }
        
                
        guard let lastPatch = patches.last else {
                await MainActor.run {
                    self.isLoadingNextData = false
                    self.isReachedEndOfData = true
                }
                return
            }
        
        let lastItemId = lastPatch.images.last?.id ?? lastPatch.video.id
        
        if let data = FeedRepository.fetchNewData(fromIndex: lastItemId){
            let videoItem = FeedItem(id: lastItemId + 1, url: data.video,isVideo: true,isAd: false)
            let imagesItem = data.images.map {
                FeedItem(id: $0.id, url:  $0.url, isVideo: false, isAd: false)
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                var newItems: [FeedItem] = []
                newItems.append(videoItem)
                newItems.append(contentsOf: imagesItem)
                self.videoItem = videoItem
                self.feedItems.append(contentsOf: self.mixAdvToFeedItems(items: imagesItem))
                self.organizeIntoPatch(newItems)
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
            let videoItems = FeedItem(id: 0, url: data.video, isVideo: true, isAd: false)
            
            let newItems = data.images.map {
                FeedItem(id: $0.id, url: $0.url, isVideo: false, isAd: false)
            }
            
            let newFeedItems: [FeedItem] = [videoItems] + newItems
            
           
            
            await MainActor.run {
                videoItem = videoItems
                feedItems.insert(contentsOf: mixAdvToFeedItems(items: newItems), at: 0)
                organizeIntoPatch(newFeedItems,isPrevData: true)
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
                    result.insert(FeedItem(id: ad.id, url: ad.url, isVideo: false, isAd: true), at: index)
                }
            }
        }
        return result
    }
    
    let imageUrls = [

            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&q=80&w=1080",
        "https://images.unsplash.com/photo-1516676158449-f9db75b6e3d?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1502630859934-b3b41d18206c?ixlib=rb-4.0.3&q=80&w=1080",
           "https://images.unsplash.com/photo-1519681393784-d120267933ba?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1530099486328-e021101a494a?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1494548162494-384bba4ab999?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1519996456112-9f80e4e421f8?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1524758631624-e2822e304c36?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1517760444937-f6397edcbbcd?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1496096265110-f83ad7f96608?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1516534775068-ba3e457a69ea?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1517456837842-2944a41879b2?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1518495973542-4542c06a5843?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1523275335684-37898b6baf30?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1513703207085-1a9f2e0e8b4b?ixlib=rb-4.0.3&q=80&w=1080",
            "https://images.unsplash.com/photo-1518623489648-a173ef7824f3?ixlib=rb-4.0.3&q=80&w=1080"
    ]

    func fetchImageSize(from url: String) {
        guard let imageURL = URL(string: url) else {
            print("Invalid URL: \(url)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                print("Image URL: \(url)")
                print("Width: \(image.size.width) pixels")
                print("Height: \(image.size.height) pixels")
                print("--------------------------------")
            }
        }
        task.resume()
    }
    
   
}
