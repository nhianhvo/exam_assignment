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
        print("🔍 Checking cache for: \(url)")
        let cachedImage = cache.object(forKey: url as NSString)
        print("📦 Cache hit: \(cachedImage != nil)")
        return cachedImage
    }
    
    func insert(_ image: UIImage, for url: String) {
        print("💾 Inserting into cache: \(url)")
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
            let urlSession = URLSession.shared
            let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            if let mimeType = httpResponse.mimeType {
                guard mimeType.hasPrefix("image/") else {
                    throw URLError(.unsupportedURL)
                }
            }
            
            if let image = UIImage(data: data) {
                await ImageCache.shared.insert(image, for: url.absoluteString)
                phase = .success(Image(uiImage: image))
            } else {
                let options: [NSData.ReadingOptions] = [.mappedIfSafe, .uncached]
                for option in options {
                    if let image = UIImage(data: data, scale: UIScreen.main.scale) {
                        await ImageCache.shared.insert(image, for: url.absoluteString)
                        phase = .success(Image(uiImage: image))
                        return
                    }
                }
                
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
