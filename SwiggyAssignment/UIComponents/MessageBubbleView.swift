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
                    VStack(alignment: .leading, spacing: 8) {
                        SwiggyChatImageView(
                            originalPath: fileInfo.path,
                            thumbnailPath: fileInfo.thumbnail?.path,
                            fixedSize: .init(width: 250, height: 300),
                            imageScaling: .fill
                        )
                        .overlay {
                            ZStack(alignment: .bottomTrailing) {
                                Color.black
                                    .opacity(0.2)
                                    .frame(width: 250, height: 300)
                                Text(ImageService.shared.formatFileSize(fileInfo.fileSize))
                                    .font(.system(size: 9, weight: .regular))
                                    .foregroundColor(.white)
                                    .padding(.trailing, 5)
                                    .padding(.bottom, 5)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            onImageTap(fileInfo.path)
                        }
                        
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
