//
//  FeedItem.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//
import Foundation

struct FeedItem: Identifiable, Codable {
    let id: UUID
    let url: String
    let isVideo: Bool
    let isAd: Bool
    let price: String?
    let tagPosition: TagPosition?
    
    struct TagPosition: Codable {
            let x: CGFloat
            let y: CGFloat
        }
    
    init(id: String, url: String, isVideo: Bool = false, isAd: Bool = false, price: String? = nil, tagPosition: TagPosition? = nil) {
            
            self.id = UUID(uuidString: id) ?? UUID()
            self.url = url
            self.isVideo = isVideo
            self.isAd = isAd
            self.price = price
            self.tagPosition = tagPosition
        }
}
