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
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            isKeyboardVisible = true
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isKeyboardVisible = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var keyboard = KeyboardObserver()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.vertical)
                }
                .onTapGesture {
                    toggleKeyboard()
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                Divider()
                MessageInputView(
                    viewModel: viewModel,
                    focusedState: $isFocused
                )
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        print("LOGS:: \(#function)")
        if let lastMessage = viewModel.messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private func toggleKeyboard() {
        print("LOGS:: \(#function)")
        if keyboard.isKeyboardVisible {
           isFocused = false
        } else {
            isFocused = true
        }
    }
}
