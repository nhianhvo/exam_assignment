//
//  AdvRepository.swift
//  ExamAssignment
//
//  Created by JonnyChinhTran on 04/03/2025.
//

class AdvRepository{
    static func fetchAdvData() -> AdData?{
        let advData: AdData = DataLoader.loadJSON("adv")
        return advData
    }
}
