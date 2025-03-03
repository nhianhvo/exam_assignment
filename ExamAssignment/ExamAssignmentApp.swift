//
//  ExamAssignmentApp.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//

import SwiftUI

@main
struct ExamAssignmentApp: App {
    
    var body: some Scene {
        WindowGroup {
            FeedView().environmentObject(AppViewModel()).onAppear{
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    let supportedOrientations: UIInterfaceOrientationMask = [.portrait, .landscape]
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: supportedOrientations))
                }
            }
        }
    }
}
