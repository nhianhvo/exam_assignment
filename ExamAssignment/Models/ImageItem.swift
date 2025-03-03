//
//  ImageItem.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//
import Foundation

struct ImageItem: Codable {
    let id: String
        let url: String
        let price: String?
        let tagPosition: TagPosition?
        
        struct TagPosition: Codable {
            let x: Double
            let y: Double
        }
}

extension ImageItem {
    func toFeedItem() -> FeedItem {
        FeedItem(id: "\(id)",
                url: url,
                price: price,
                tagPosition: tagPosition.map { FeedItem.TagPosition(x: $0.x, y: $0.y) })
    }
}
