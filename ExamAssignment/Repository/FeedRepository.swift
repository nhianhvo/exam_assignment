//
//  FeedRepository.swift
//  ExamAssignment
//
//  Created by JonnyChinhTran on 04/03/2025.
//

class FeedRepository {
    static let totalItems = 60

    static func fetchNewData(fromIndex: Int) -> FeedData?{
        if fromIndex >= totalItems - 1{
            return nil
        }
        let data: FeedData = DataLoader.loadJSON("next")
        return data
    }
    
    static func fetchOldData(fromIndex: Int) -> FeedData?{
        if fromIndex <= 0{
            return nil
        }
        let data: FeedData = DataLoader.loadJSON("prev")
        return data
    }
    
    static func fetchData() -> FeedData{
        let data: FeedData = DataLoader.loadJSON("current")
        return data
    }
}
