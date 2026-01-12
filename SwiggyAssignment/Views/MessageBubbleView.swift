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
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
            }
            
            VStack(alignment: bubbleAlignment, spacing: 4) {
                messageBubbleContent
                
                if showTime {
                    timestampView
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
    
    // MARK: - Computed Properties
    
    private var isFromUser: Bool {
        message.sender == .user
    }
    
    private var bubbleAlignment: HorizontalAlignment {
        isFromUser ? .trailing : .leading
    }
    
    private var roundedCorners: UIRectCorner {
        guard showMessageTail else { return .allCorners }
        return [isFromUser ? .topLeft : .topRight, .bottomLeft, .bottomRight]
    }
    
    private var userBubbleColor: Color {
        Color(red: 0.9, green: 0.95, blue: 1.0)
    }
    
    private var agentBubbleColor: Color {
        Color(.systemGray6)
    }
    
    private var bubbleColor: Color {
        isFromUser ? .blue : Color(.systemGray5)
    }
    
    private var textColor: Color {
        isFromUser ? .white : .primary
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var messageBubbleContent: some View {
        if message.type == .file, let fileInfo = message.file {
            imageMessageView(fileInfo: fileInfo)
        } else {
            textMessageView
        }
    }
    
    private func imageMessageView(fileInfo: FileInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            imageWithOverlay(fileInfo: fileInfo)
            
            if !message.message.isEmpty {
                captionView
            }
        }
        .frame(width: 250)
        .padding(8)
        .background(isFromUser ? userBubbleColor : agentBubbleColor)
        .clipShape(RoundedCorner(radius: 16, corners: roundedCorners))
        .bubbleTail(
            show: showMessageTail,
            isFromUser: isFromUser,
            color: isFromUser ? userBubbleColor : agentBubbleColor
        )
    }
    
    private func imageWithOverlay(fileInfo: FileInfo) -> some View {
        SwiggyChatImageView(
            originalPath: fileInfo.path,
            thumbnailPath: fileInfo.thumbnail?.path,
            fixedSize: CGSize(width: 250, height: 300),
            imageScaling: .fill
        )
        .overlay {
            fileSizeOverlay(fileSize: fileInfo.fileSize)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            onImageTap(fileInfo.path)
        }
    }
    
    private func fileSizeOverlay(fileSize: Int64) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.opacity(0.2)
            
            Text(ImageService.shared.formatFileSize(fileSize))
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(.white)
                .padding(.trailing, 5)
                .padding(.bottom, 5)
        }
        .frame(width: 250, height: 300)
    }
    
    private var captionView: some View {
        Text(message.message)
            .padding(.vertical, 3)
            .contextMenu {
                copyButton
            }
    }
    
    private var textMessageView: some View {
        Text(message.message)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(bubbleColor)
            .foregroundColor(textColor)
            .clipShape(RoundedCorner(radius: 10, corners: roundedCorners))
            .bubbleTail(
                show: showMessageTail,
                isFromUser: isFromUser,
                color: bubbleColor
            )
            .contextMenu {
                copyButton
            }
    }
    
    private var timestampView: some View {
        Text(message.formattedTime)
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding(.horizontal, 4)
    }
    
    private var copyButton: some View {
        Button(action: copyMessageText) {
            Label("Copy Text", systemImage: "doc.on.doc")
        }
    }
    
    // MARK: - Actions
    
    private func copyMessageText() {
        UIPasteboard.general.string = message.message
        showCopyAlert = true
    }
}

// MARK: - View Extensions

extension View {
    func bubbleTail(show: Bool, isFromUser: Bool, color: Color) -> some View {
        self.background(alignment: isFromUser ? .topTrailing : .topLeading) {
            if show {
                BubbleTailShape(isFromUser: isFromUser)
                    .fill(color)
                    .frame(width: 35, height: 30)
                    .offset(x: isFromUser ? 10 : -10)
            } else {
                Color.clear
            }
        }
    }
}
