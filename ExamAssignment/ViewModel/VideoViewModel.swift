//
//  VideoViewModel.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/4/25.
//
import AVKit


class VideoViewModel: ObservableObject {
    @Published private(set) var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var lastPlaybackTime: CMTime?
    private var wasPlaying: Bool = false
    static let shared = VideoViewModel()
    
    func setupPlayer(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        if player != nil,let savedTime = lastPlaybackTime {
            print("🎥 Restoring player state")
                        player?.seek(to: savedTime) { [weak self] finished in
                            if finished, self?.wasPlaying == true {
                                self?.player?.play()
                            }
                        }
            return
        }
        
        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        // Thêm observer để lưu thời điểm hiện tại
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { [weak self] time in
            self?.lastPlaybackTime = time
        }
        
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func play() {
        player?.play()
    }
    
    func cleanup() {
        
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        player?.pause()
        player = nil
    }
    
    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player = nil
        playerItem = nil
    }
}
