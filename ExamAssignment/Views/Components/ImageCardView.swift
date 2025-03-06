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
                                    
                                    if let (x, y) = tagPosition, !isAd {
                                        ZStack {
                                            Circle()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.blue)
                                                .position(x: x, y: y)
                                                .onTapGesture {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        showTag.toggle()
                                                    }
                                                }
                                            Circle()
                                                .frame(width: 16, height: 16)
                                                .foregroundColor(.white)
                                                .position(x: x, y: y)
                                                .onTapGesture {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        showTag.toggle()
                                                    }
                                                }
                                            Circle()
                                                .frame(width: 7, height: 7)
                                                .foregroundColor(.blue)
                                                .position(x: x, y: y)
                                                .onTapGesture {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        showTag.toggle()
                                                    }
                                                }
                                        }
                                        if showTag, let price = tagPrice {
                                            let tagHeight: CGFloat = 40
                                            let tagWidth: CGFloat = 100
                                            
                                            let isTopHalf = y < geometry.size.height / 2
                                            let spacing: CGFloat = isTopHalf ? 10 : 5
                                            
                                            let priceY = isTopHalf ?
                                            min(y + tagHeight/2 + spacing, geometry.size.height - tagHeight/2) :
                                            max(y - tagHeight/2 - spacing, tagHeight/2)
                                            
                                            let priceX = max(tagWidth/2, min(x, geometry.size.width - tagWidth/2))
                                            
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
    
    private func loadTags(_ size: CGSize, priceTagItem: PriceTagItem) {
        tagPosition = (size.width * priceTagItem.x, size.height * priceTagItem.y)
        tagPrice = priceTagItem.price
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

