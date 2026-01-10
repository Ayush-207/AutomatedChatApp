//
//  SwiggyChatImageView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 11/01/26.
//
import SwiftUI

struct SwiggyChatImageView: View {
    let originalPath: String
    let thumbnailPath: String?

    @State private var image: UIImage?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
                    .onAppear {
                        loadIfNeeded()
                    }
            }
        }
    }

    private func loadIfNeeded() {
        guard !isLoading else { return }
        isLoading = true

        if let thumb = thumbnailPath {
            ImageService.shared.loadImage(from: thumb) { loaded in
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
            .frame(width: 200, height: 200)
            .overlay(
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            )
    }
}

