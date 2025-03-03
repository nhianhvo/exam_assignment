//
//  CacheAsyncImage.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//
import SwiftUI

actor ImageCache {
    static let shared = ImageCache()
    private var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        return cache
    }()
    
    func image(for url: String) -> UIImage? {
        cache.object(forKey: url as NSString)
    }
    
    func insert(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
}

struct CachedAsyncImage<Content: View>: View {
    let url: URL?
    let content: (AsyncImagePhase) -> Content
    
    @State private var phase: AsyncImagePhase = .empty
    private let cache = URLCache.shared
    
    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
    }
    
    var body: some View {
        content(phase)
            .task(id: url?.absoluteString) {
                await loadImage()
            }
    }
    
    private func loadImage() async {
        guard let url = url else {
            phase = .failure(URLError(.badURL))
            return
        }
        
        if let cacheImage = await ImageCache.shared.image(for: url.absoluteString) {
            phase = .success(Image(uiImage: cacheImage))
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let image = UIImage(data: data) {
                await ImageCache.shared.insert(image, for: url.absoluteString)
                phase = .success(Image(uiImage: image))
            } else {
                phase = .failure(URLError(.cannotDecodeContentData))
            }
        } catch {
            phase = .failure(error)
        }
    }
}

extension CachedAsyncImage {
    init(url: URL?) where Content == Image {
        self.init(url: url) { phase in
            phase.image ?? Image(systemName: "photo")
        }
    }
}
