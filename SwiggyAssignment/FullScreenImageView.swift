//
//  FullScreenImageView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import SwiftUI

struct FullScreenImageView: View {
    let imagePath: String
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                Spacer()
                
                if imagePath.hasPrefix("http") {
                    AsyncImage(url: URL(string: imagePath)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(scale)
                                .gesture(
                                    buildMagnificationGesture()
                                )
                                .onTapGesture(count: 2) {
                                    onDoubleTapGesture()
                                }
                        case .failure:
                            Text("Failed to load image")
                                .foregroundColor(.white)
                        case .empty:
                            ProgressView()
                                .tint(.white)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    if let image = ImageService.shared.loadImage(from: imagePath) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .gesture(
                                buildMagnificationGesture()
                            )
                            .onTapGesture(count: 2) {
                                onDoubleTapGesture()
                            }
                    }
                }
                
                Spacer()
            }
        }
    }
    
    func onDoubleTapGesture() {
        withAnimation {
            if scale > 1 {
                scale = 1
                lastScale = 1
            } else {
                scale = 2
                lastScale = 2
            }
        }
    }
    
    func buildMagnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = lastScale * value
            }
            .onEnded { _ in
                lastScale = scale
                if scale < 1 {
                    withAnimation {
                        scale = 1
                        lastScale = 1
                    }
                }
            }
    }
}
