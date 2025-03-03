//
//  FeedItem.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//

struct FeedItem: Identifiable, Codable {
    let id: String
    let url: String
    let isVideo: Bool
    let isAd: Bool
}
