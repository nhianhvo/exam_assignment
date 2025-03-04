//
//  VideoView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//

import SwiftUI
import AVKit

struct VideoView: View {
    let url: String
    @ObservedObject var viewModel: VideoViewModel
    
    var body: some View {
        VideoPlayer(player: viewModel.player)
            .onAppear {
                viewModel.setupPlayer(with: url)
            }.id("VideoPlayer")
//            .onDisappear {
//                viewModel.cleanup()
//            }
    }
}
