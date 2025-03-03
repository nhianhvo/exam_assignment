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
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player = AVPlayer(url: URL(string: url)!)
                player?.play()
            }
            .onDisappear {
                player?.pause()
            }
    }
}
