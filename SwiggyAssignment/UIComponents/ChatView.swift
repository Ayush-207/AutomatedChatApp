//
//  ChatView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import SwiftUI
import Combine

final class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    @Published var keyboardHeight: CGFloat = 0
    @Published var duration: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            isKeyboardVisible = true
            
            if let height = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = height.height
            }
            
            if let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat {
                duration = animationDuration
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isKeyboardVisible = false
            self?.keyboardHeight = 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

struct ChatScreenView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool
        
    var body: some View {
        VStack(spacing: 0) {
            ChatView(viewModel: viewModel)
            Divider()
            MessageInputView(viewModel: viewModel, isTextFieldFocused: $isInputFocused)
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

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    if viewModel.hasMoreMessages {
                        Button(action: {
                            viewModel.loadMoreMessages()
                        }) {
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .padding()
                            } else {
                                Text("Load More")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                    }
                    
                    ForEach(viewModel.displayedMessages) { message in
                        MessageBubbleView(message: message) { imagePath in
                            viewModel.selectedImageForFullScreen = imagePath
                        }
                        .id(message.id)
                    }
                    if viewModel.isAgentTyping {
                        TypingIndicatorView()
                    }
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .id("BOTTOM")
                }
                .padding(.vertical)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .onChange(of: viewModel.displayedMessages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isAgentTyping)  { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onAppear {
                scrollToBottom(proxy: proxy, animated: false)
            }
        }
    }
    
    private func scrollToBottom(
        proxy: ScrollViewProxy,
        animated: Bool = true,
        withDuration duration: CGFloat = 0.3) {
        guard viewModel.scrollToBottom else { return }
        viewModel.scrollToBottom = false
        if animated {
            withAnimation(.easeOut(duration: duration)) {
                proxy.scrollTo("BOTTOM", anchor: .bottom)
            }
        } else {
            proxy.scrollTo("BOTTOM", anchor: .bottom)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ImageWrapper: Identifiable {
    let id = UUID()
    let path: String
}

#Preview {
    NavigationStack {
        ChatScreenView()
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
