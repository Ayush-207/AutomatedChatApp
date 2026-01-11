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
}

struct SwiggyChatImageView: View {
    let originalPath: String
    let thumbnailPath: String?

    @State private var image: UIImage?
    @State private var isLoading = false
    
    var fixedSize: CGSize?
    var imageScaling: ChatImageScaling

    var body: some View {
        ZStack {
            if let image {
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
        }
    }

    private func loadIfNeeded() {
        guard !isLoading else { return }
        isLoading = true

        if let thumb = thumbnailPath {
//            print("LOGS:: thumbnailPath \(thumb)")
            ImageService.shared.loadImage(from: thumb, isThumbnail: true) { loaded in
                if let loaded = loaded {
                    self.image = loaded
                } else {
                    ImageService.shared.loadImage(from: originalPath) {
                        //TODO: Handle failure case
                        self.image = $0
                    }
                }
            }
        } else {
            ImageService.shared.loadImage(from: originalPath) { self.image = $0 }
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
}

