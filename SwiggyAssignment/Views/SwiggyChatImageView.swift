//
//  SwiggyChatImageView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 11/01/26.
//
import SwiftUI

enum ChatImageScaling {
    case fit
    case fill
    case none
}

struct SwiggyChatImageView: View {
    let originalPath: String
    let thumbnailPath: String?

    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var imageFailedToLoad = false
    
    var fixedSize: CGSize?
    var imageScaling: ChatImageScaling

    var body: some View {
        ZStack {
            if imageFailedToLoad {
                errorView
            } else if let image {
                getImageView(image)
            } else {
                placeholder
                    .onAppear {
                        loadIfNeeded()
                    }
            }
        }
        .frame(width: fixedSize != nil ? fixedSize?.width : nil, height: fixedSize != nil ? fixedSize?.height : nil)
    }
    
    @ViewBuilder
    func getImageView(_ image: UIImage) -> some View {
        let base = Image(uiImage: image)
                    .resizable()

        switch imageScaling {
        case .fill:
            base.scaledToFill()
        case .fit:
            base.scaledToFit()
        case .none:
            base
        }
    }

    private func loadIfNeeded() {
        print("LOGS:: \(#function)")
        guard !isLoading else { return }
        isLoading = true

        if let thumb = thumbnailPath {
            ImageService.shared.loadImage(from: thumb, isThumbnail: true) { loaded in
                if let loaded = loaded {
                    withAnimation(.easeIn(duration: 0.2)) {
                        isLoading = false
                        imageFailedToLoad = false
                        self.image = loaded
                    }
                } else {
                    loadOriginalImage()
                }
            }
        } else {
            loadOriginalImage()
        }
    }
    
    private func loadOriginalImage() {
        ImageService.shared.loadImage(from: originalPath) { image in
            isLoading = false
            if let image = image {
                withAnimation(.easeIn(duration: 0.2)) {
                    self.image = image
                    imageFailedToLoad = false
                }
            } else {
                withAnimation(.easeIn(duration: 0.2)) {
                    imageFailedToLoad = true
                }
            }
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            )
    }
    
    private var errorView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                Text("FAILED TO LOAD IMAGE")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                Button {
                    imageFailedToLoad = false
                    isLoading = false
                    loadIfNeeded()
                } label: {
                    Text("RETRY")
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.blue.cornerRadius(4))
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        }
    }
}

