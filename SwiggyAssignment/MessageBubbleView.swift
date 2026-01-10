//
//  MessageBubbleView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let onImageTap: (String) -> Void
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                if message.type == .file, let fileInfo = message.file {
                    VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 8) {
                        if fileInfo.path.hasPrefix("http") {
                            AsyncImage(url: URL(string: fileInfo.path)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: 250, maxHeight: 300)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .onTapGesture {
                                            onImageTap(fileInfo.path)
                                        }
                                case .failure:
                                    placeholderImage
                                case .empty:
                                    ProgressView()
                                        .frame(width: 200, height: 200)
                                @unknown default:
                                    placeholderImage
                                }
                            }
                        } else {
                            if let image = ImageService.shared.loadImage(from: fileInfo.path) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: 250, maxHeight: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .onTapGesture {
                                        onImageTap(fileInfo.path)
                                    }
                            } else {
                                placeholderImage
                            }
                        }
                        
                        Text(ImageService.shared.formatFileSize(fileInfo.fileSize))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if !message.message.isEmpty {
                            Text(message.message)
                                .padding(.vertical, 2)
                        }
                    }
                    .frame(maxWidth: 250)
                    .padding(8)
                    .background(message.sender == .user ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .cornerRadius(16)
                } else {
                    Text(message.message)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(message.sender == .user ? Color.blue : Color(.systemGray5))
                        .foregroundColor(message.sender == .user ? .white : .primary)
                        .cornerRadius(16)
                }
                
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if message.sender == .agent {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
    
    private var placeholderImage: some View {
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
