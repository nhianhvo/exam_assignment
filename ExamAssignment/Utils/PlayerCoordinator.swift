//
//  PlayerCoordinator.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/5/25.
//
import Foundation

class PlayerCoordinator: ObservableObject {
    static let shared = PlayerCoordinator()
    @Published var currentPlayingId: Int?
    
    func setCurrentPlaying(_ id: Int) {
        currentPlayingId = id
    }
}
