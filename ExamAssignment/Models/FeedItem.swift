//
//  FeedItem.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//

struct FeedItem: Identifiable, Codable {
    let id: Int
    let url: String
    let isVideo: Bool
    let isAd: Bool
    let width: Int?
    let height: Int?
    let price_tags: [PriceTagItem]?
}
