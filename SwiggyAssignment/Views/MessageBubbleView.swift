//
//  MessageBubbleView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct MessageBubbleView: View {
    let showMessageTail: Bool
    let showTime: Bool
    let message: Message
    let onImageTap: (String) -> Void
    @State private var showCopyAlert = false
    
    var roundedCorners: UIRectCorner {
        guard showMessageTail else {
            return [.allCorners]
        }
        return [(message.sender == .user ? .topLeft : .topRight), .bottomLeft, .bottomRight]
    }
    
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
                        .contentShape(RoundedRectangle(cornerRadius: 12))
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
                    .background(message.sender == .user ? Color(
                        red: 0.9,
                        green: 0.95,
                        blue: 1.0
                    ) : Color(.systemGray6))
                    .clipShape(RoundedCorner(radius: 16, corners: roundedCorners))
                    .background(alignment: message.sender == .user ? .topTrailing : .topLeading) {
                        if showMessageTail {
                            BubbleTailShape(isFromUser: message.sender == .user)
                                .fill(message.sender == .user ? Color(
                                    red: 0.9,
                                    green: 0.95,
                                    blue: 1.0
                                ) : Color(.systemGray6))
                                .frame(width: 35, height: 30)
                                .offset(x: message.sender == .user ? 10 : -10)
                        } else {
                            Color.clear
                        }
                    }
                } else {
                    Text(message.message)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(message.sender == .user ? Color.blue : Color(.systemGray5))
                        .foregroundColor(message.sender == .user ? .white : .primary)
                        .clipShape(RoundedCorner(radius: 10, corners: roundedCorners))
                        .background(alignment: message.sender == .user ? .topTrailing : .topLeading) {
                            if showMessageTail {
                                BubbleTailShape(isFromUser: message.sender == .user)
                                    .fill(message.sender == .user ? Color.blue : Color(.systemGray5))
                                    .frame(width: 35, height: 30)
                                    .offset(x: message.sender == .user ? 10 : -10)
                            } else {
                                Color.clear
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = message.message
                                showCopyAlert = true
                            }) {
                                Label("Copy Text", systemImage: "doc.on.doc")
                            }
                        }
                }
                
                if showTime {
                    Text(message.formattedTime)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
            }
            
            if message.sender == .agent {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 2)
        .padding(.top, showMessageTail ? 2 : -6)
        .alert("Copied", isPresented: $showCopyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Message copied to clipboard")
        }
    }
}

#Preview {
    VStack {
//        MessageBubbleView(message: Message(
//            id: "1",
//            message: "Hello! How can I help you today?",
//            type: .text,
//            file: nil,
//            sender: .agent,
//            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
//        ), onImageTap: { _ in })
//        
//        MessageBubbleView(message: Message(
//            id: "2",
//            message: "I need help with my booking",
//            type: .text,
//            file: nil,
//            sender: .user,
//            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
//        ), onImageTap: { _ in })
        BubbleTailShape(isFromUser: true)
            .frame(width: 14, height: 10)
    }
}
