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
    @State private var showTag = false
    @State private var tagPosition: (x: CGFloat, y: CGFloat)? = nil
    @State private var tagPrice: String? = nil
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .overlay(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        loadTags(geometry.size)
                                    }
                            }
                        )
                case .failure:
                    Color.gray
                case .empty:
                    ProgressView()
                @unknown default:
                    Color.gray
                }
            }
            
//            if let (x, y) = tagPosition, !isAd {
//                Circle()
//                    .frame(width: 10, height: 10)
//                    .foregroundColor(.blue)
//                    .position(x: x, y: y)
//                    .onTapGesture {
//                        withAnimation(.easeInOut(duration: 0.3)) {
//                            showTag.toggle()
//                        }
//                    }
//            }
            
            if showTag, let price = tagPrice, !isAd {
                VStack {
                    Text(price)
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(5)
                        .shadow(radius: 2)
                }
                .position(x: tagPosition?.x ?? 0, y: (tagPosition?.y ?? 0) + 20)
                .transition(.opacity)
            }
        }
        .overlay(
            isAd ? Text("Ad").font(.caption).foregroundColor(.white).padding(5).background(Color.black.opacity(0.7)).cornerRadius(5) : nil,
            alignment: .topLeading
        )
    }
    
    private func loadTags(_ size: CGSize) {
        tagPosition = (size.width * 0.5, size.height * 0.5)
        tagPrice = "$99.99"
    }
}
