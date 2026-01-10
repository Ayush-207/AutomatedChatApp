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
    @State private var showCopyAlert = false
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                if message.type == .file, let fileInfo = message.file {
                    VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 8) {
                        SwiggyChatImageView(originalPath: fileInfo.path, thumbnailPath: fileInfo.thumbnail?.path)
                        .scaledToFill()
                        .frame(width: 250, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            onImageTap(fileInfo.path)
                        }
                        Text(ImageService.shared.formatFileSize(fileInfo.fileSize))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if !message.message.isEmpty {
                            Text(message.message)
                                .padding(.vertical, 3)
                                .contextMenu {
                                    Button(action: {
                                        UIPasteboard.general.string = message.message
                                        showCopyAlert = true
                                    }) {
                                        Label("Copy Text", systemImage: "doc.on.doc")
                                    }
                                }
                        }
                    }
                    .frame(width: 250)
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
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = message.message
                                showCopyAlert = true
                            }) {
                                Label("Copy Text", systemImage: "doc.on.doc")
                            }
                        }
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
        .alert("Copied", isPresented: $showCopyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Message copied to clipboard")
        }
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

#Preview {
    VStack {
        MessageBubbleView(message: Message(
            id: "1",
            message: "Hello! How can I help you today?",
            type: .text,
            file: nil,
            sender: .agent,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        ), onImageTap: { _ in })
        
        MessageBubbleView(message: Message(
            id: "2",
            message: "I need help with my booking",
            type: .text,
            file: nil,
            sender: .user,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        ), onImageTap: { _ in })
    }
}
