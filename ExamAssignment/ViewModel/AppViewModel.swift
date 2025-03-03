//
//  AppViewModel.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//

import SwiftUI

class AppViewModel: ObservableObject {
    @Published var orientation = UIDevice.current.orientation
    @Published var isLandscape: Bool = false
    private var orientationObserver: NSObjectProtocol?
    
    init() {
        orientationObserver = NotificationCenter.default.addObserver(
                    forName: UIDevice.orientationDidChangeNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    guard let self = self else { return }
                    let newIsLandscape = UIDevice.current.orientation.isLandscape
                    if self.isLandscape != newIsLandscape {
                        self.isLandscape = newIsLandscape
                    }
                }
    }
    
    deinit {
            if let observer = orientationObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
}
