//
//  ChatScreenView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 12/01/26.
//
import SwiftUI

struct ChatScreenView: View {
    @StateObject private var viewModel = ChatViewModel()
        
    var body: some View {
        VStack(spacing: 0) {
            ChatView(viewModel: viewModel)
            Divider()
            MessageInputView(viewModel: viewModel)
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: Binding(
            get: { viewModel.selectedImageForFullScreen.map { ImageWrapper(path: $0) } },
            set: { viewModel.selectedImageForFullScreen = $0?.path }
        )) { wrapper in
            FullScreenImageView(imagePath: wrapper.path)
        }
    }
}
