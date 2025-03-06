//
//  ImageCardView.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//

import SwiftUI

struct ImageCardView: View {
    let url: String
    let isAd: Bool
    let preferWidth: CGFloat?
    let preferHeight: CGFloat?
    let targetWidth: CGFloat?
    let priceTags: [PriceTagItem]?
    @State private var showTag = false
    @State private var tagPosition: (x: CGFloat, y: CGFloat)? = nil
    @State private var tagPrice: String? = nil
    
    @State private var tagPositions: [String: (CGFloat, CGFloat)] = [:]  // Nếu position là (CGFloat, CGFloat)
        @State private var tagPrices: [String: String] = [:]  // Dictionary để lưu giá tương ứng
        @State private var showTags: Set<String> = []  // Set để track những tag nào đang hiển thị
    
    var body: some View {
        ZStack {
            CachedAsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .overlay(
                            GeometryReader { geometry in
                                ZStack {
                                    Color.clear
                                        .onAppear {
                                            if let tags = priceTags {
                                                for tag in tags {
                                                    loadTags(geometry.size, priceTagItem: tag)
                                                }
                                            }
                                            
                                        }
                                    
                                    ForEach(priceTags ?? [], id: \.self) { tag in
                                        let tagKey = makeTagKey(tag)
                                        if let position = tagPositions[tagKey] {
                                            Group {  // Wrap trong Group để tránh nhiều view trong ForEach
                                                ZStack {
                                                    // Tag point
                                                    Circle()
                                                        .stroke(Color.blue, lineWidth: 1.5)
                                                        .frame(width: 20, height: 20)
                                                        .shadow(color: .white.opacity(0.5), radius: 2)
                                                    
                                                    Circle()
                                                        .fill(Color.blue)
                                                        .frame(width: 7, height: 7)
                                                }
                                                .position(x: position.0, y: position.1)  // Sử dụng tuple index vì position là (CGFloat, CGFloat)
                                                .onTapGesture {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        if showTags.contains(tagKey) {
                                                            showTags.remove(tagKey)
                                                        } else {
                                                            showTags.insert(tagKey)
                                                        }
                                                    }
                                                }
                                                
                                                // Price tag
                                                if showTags.contains(tagKey), let price = tagPrices[tagKey] {
                                                    let tagHeight: CGFloat = 40
                                                    let tagWidth: CGFloat = 100
                                                    let spacing: CGFloat = 15
                                                    
                                                    let isTopHalf = position.1 < geometry.size.height / 2  // Sử dụng tuple index
                                                    
                                                    let priceY = isTopHalf ?
                                                        min(position.1 + tagHeight/2 + spacing, geometry.size.height - tagHeight/2) :
                                                        max(position.1 - tagHeight/2 - spacing, tagHeight/2)
                                                    
                                                    let priceX = max(tagWidth/2, min(position.0, geometry.size.width - tagWidth/2))  // Sử dụng tuple index
                                                    
                                                    VStack {
                                                        Text(price)
                                                            .font(.subheadline)
                                                            .padding(8)
                                                            .background(Color.white)
                                                            .cornerRadius(5)
                                                            .shadow(radius: 2)
                                                    }
                                                    .position(x: priceX, y: priceY)
                                                    .transition(.opacity)
                                                }
                                            }
                                        }
                                    }
                                    
//                                    if let (x, y) = tagPosition, !isAd {
//                                        ZStack {
//                                            Circle()
//                                                .frame(width: 20, height: 20)
//                                                .foregroundColor(.blue)
//                                                .position(x: x, y: y)
//                                                .onTapGesture {
//                                                    withAnimation(.easeInOut(duration: 0.3)) {
//                                                        showTag.toggle()
//                                                    }
//                                                }
//                                            Circle()
//                                                .frame(width: 16, height: 16)
//                                                .foregroundColor(.white)
//                                                .position(x: x, y: y)
//                                                .onTapGesture {
//                                                    withAnimation(.easeInOut(duration: 0.3)) {
//                                                        showTag.toggle()
//                                                    }
//                                                }
//                                            Circle()
//                                                .frame(width: 7, height: 7)
//                                                .foregroundColor(.blue)
//                                                .position(x: x, y: y)
//                                                .onTapGesture {
//                                                    withAnimation(.easeInOut(duration: 0.3)) {
//                                                        showTag.toggle()
//                                                    }
//                                                }
//                                        }
//                                        if showTag, let price = tagPrice {
//                                            let tagHeight: CGFloat = 40
//                                            let tagWidth: CGFloat = 100
//                                            
//                                            let isTopHalf = y < geometry.size.height / 2
//                                            let spacing: CGFloat = isTopHalf ? 10 : 5
//                                            
//                                            let priceY = isTopHalf ?
//                                            min(y + tagHeight/2 + spacing, geometry.size.height - tagHeight/2) :
//                                            max(y - tagHeight/2 - spacing, tagHeight/2)
//                                            
//                                            let priceX = max(tagWidth/2, min(x, geometry.size.width - tagWidth/2))
//                                            
//                                            VStack {
//                                                Text(price)
//                                                    .font(.subheadline)
//                                                    .padding(8)
//                                                    .background(Color.white)
//                                                    .cornerRadius(5)
//                                                    .shadow(radius: 2)
//                                            }
//                                            .position(x: priceX, y: priceY)
//                                            .transition(.opacity)
//                                        }
//                                    }
                                    
                                    
                                }
                                
                            }
                        )
                case .failure:
                    failureView
                case .empty:
                    loadingView
                @unknown default:
                    unknownView
                }
            }
        }
        .overlay(
            
            isAd ? Text("Ad").font(.caption).foregroundColor(.white).padding(5).background(Color.black.opacity(0.7)).cornerRadius(5) : nil,
            alignment: .topLeading
        )
    }
    
    private func makeTagKey(_ tag: PriceTagItem) -> String {
            return "\(tag.x)-\(tag.y)"
        }
    
    private func loadTags(_ size: CGSize, priceTagItem: PriceTagItem) {
            let position: (CGFloat, CGFloat) = (size.width * priceTagItem.x, size.height * priceTagItem.y)
            let key = makeTagKey(priceTagItem)
            tagPositions[key] = position
            tagPrices[key] = priceTagItem.price
        }
    
    
    private var loadingView: some View {
        var targetHeight: CGFloat = 50
        if let preferWidth = preferWidth{
            targetHeight = (targetWidth ?? 0)*(preferHeight ?? 0)/preferWidth
        }
        return ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .frame(width: targetWidth, height: targetHeight)
            ProgressView()
                .tint(.gray)
        }
    }
    private var failureView: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .cornerRadius(10)
            
            VStack(spacing: 8) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("Image not found")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var unknownView: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .cornerRadius(10)
            
            VStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("Unknown error")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
}

