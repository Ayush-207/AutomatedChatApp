//
//  ChatView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//
import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @StateObject private var keyboard = KeyboardObserver()
    
    @State private var scrollWorkItem: DispatchWorkItem?
    @State private var bottomViewYOrigin: CGFloat = 0
    @State private var chatViewHeight: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                if viewModel.displayedMessages.isEmpty {
                    emptyChatView
                } else {
                    messagesScrollView
                        .setupScrollBehavior(
                            proxy: proxy,
                            viewModel: viewModel,
                            keyboard: keyboard,
                            bottomViewYOrigin: $bottomViewYOrigin,
                            chatViewHeight: $chatViewHeight,
                            scrollWorkItem: $scrollWorkItem
                        )
                }
                
                if shouldShowFastScrollButton {
                    fastScrollButton {
                        scrollToBottomWithFlag(proxy: proxy)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isAtBottom: Bool {
        let difference = bottomViewYOrigin - chatViewHeight
        return abs(difference) <= 40
    }
    
    private var shouldShowFastScrollButton: Bool {
        keyboard.height + chatViewHeight + 100.0 < bottomViewYOrigin
    }
    
    // MARK: - View Components
    private var emptyChatView: some View {
        ZStack(alignment: .center) {
            Color.clear
            VStack(spacing: 10) {
                Text("Start Chatting")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Image(systemName: "message")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var messagesScrollView: some View {
        ScrollView {
            VStack(spacing: 8) {
                loadMoreButton
                messagesList
                typingIndicator
                bottomAnchor
            }
            .padding(.vertical)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: hideKeyboard)
    }
    
    @ViewBuilder
    private var loadMoreButton: some View {
        if viewModel.hasMoreMessages {
            Button(action: viewModel.loadMoreMessages) {
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
    }
    
    private var messagesList: some View {
        ForEach(Array(viewModel.displayedMessages.enumerated()), id: \.element.id) { index, message in
            MessageBubbleView(
                showMessageTail: viewModel.showMessageTail(for: index),
                showTime: viewModel.showTime(for: index),
                message: message
            ) { imagePath in
                viewModel.selectedImageForFullScreen = imagePath
            }
            .id(message.id)
        }
    }
    
    @ViewBuilder
    private var typingIndicator: some View {
        if viewModel.isAgentTyping {
            TypingIndicatorView()
        }
    }
    
    private var bottomAnchor: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: 1)
            .id("BOTTOM")
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geo.frame(in: .scrollView)
                    )
                }
            )
    }
    
    private func fastScrollButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray)
                    .frame(width: 24, height: 24)
                
                Image(systemName: "chevron.down.2")
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
            }
        }
        .padding(.bottom, 12)
        .padding(.trailing, 12)
    }
    
    // MARK: - Actions
    
    private func scrollToBottomWithFlag(proxy: ScrollViewProxy) {
        viewModel.scrollToBottom = true
        performScrollToBottom(proxy: proxy)
    }
    
    private func performScrollToBottom(proxy: ScrollViewProxy, shouldAnimate: Bool = true) {
        guard scrollWorkItem == nil, viewModel.scrollToBottom else { return }
        
        let task = DispatchWorkItem {
            if shouldAnimate {
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                }
            } else {
                proxy.scrollTo("BOTTOM", anchor: .bottom)
            }
            scrollWorkItem = nil
            viewModel.scrollToBottom = false
        }
        
        scrollWorkItem = task
        let delay = shouldAnimate ? 0.05 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - View Extensions

private extension View {
    func setupScrollBehavior(
        proxy: ScrollViewProxy,
        viewModel: ChatViewModel,
        keyboard: KeyboardObserver,
        bottomViewYOrigin: Binding<CGFloat>,
        chatViewHeight: Binding<CGFloat>,
        scrollWorkItem: Binding<DispatchWorkItem?>
    ) -> some View {
        self
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { frame in
                bottomViewYOrigin.wrappedValue = frame.origin.y
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            chatViewHeight.wrappedValue = geometry.frame(in: .local).height
                        }
                        .onChange(of: geometry.frame(in: .local)) {
                            chatViewHeight.wrappedValue = geometry.frame(in: .local).height
                        }
                }
            )
            .onChange(of: viewModel.displayedMessages.count) { _, _ in
                performScroll(proxy: proxy, viewModel: viewModel, scrollWorkItem: scrollWorkItem)
            }
            .onChange(of: keyboard.height) { oldValue, newValue in
                handleKeyboardChange(
                    oldValue: oldValue,
                    newValue: newValue,
                    proxy: proxy,
                    viewModel: viewModel,
                    keyboard: keyboard,
                    chatViewHeight: chatViewHeight.wrappedValue,
                    bottomViewYOrigin: bottomViewYOrigin.wrappedValue,
                    scrollWorkItem: scrollWorkItem
                )
            }
            .onChange(of: viewModel.isAgentTyping) { _, _ in
                performScroll(proxy: proxy, viewModel: viewModel, scrollWorkItem: scrollWorkItem)
            }
            .onAppear {
                performScroll(proxy: proxy, viewModel: viewModel, scrollWorkItem: scrollWorkItem, shouldAnimate: false)
            }
    }
    
    private func performScroll(
        proxy: ScrollViewProxy,
        viewModel: ChatViewModel,
        scrollWorkItem: Binding<DispatchWorkItem?>,
        shouldAnimate: Bool = true
    ) {
        guard scrollWorkItem.wrappedValue == nil, viewModel.scrollToBottom else { return }
        
        let task = DispatchWorkItem {
            if shouldAnimate {
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                }
            } else {
                proxy.scrollTo("BOTTOM", anchor: .bottom)
            }
            scrollWorkItem.wrappedValue = nil
            viewModel.scrollToBottom = false
        }
        
        scrollWorkItem.wrappedValue = task
        let delay = shouldAnimate ? 0.05 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
    }
    
    private func handleKeyboardChange(
        oldValue: CGFloat,
        newValue: CGFloat,
        proxy: ScrollViewProxy,
        viewModel: ChatViewModel,
        keyboard: KeyboardObserver,
        chatViewHeight: CGFloat,
        bottomViewYOrigin: CGFloat,
        scrollWorkItem: Binding<DispatchWorkItem?>
    ) {
        let keyboardIsOpening = newValue > oldValue
        let shouldScroll = keyboard.height + chatViewHeight > bottomViewYOrigin
        
        if keyboardIsOpening && shouldScroll {
            viewModel.scrollToBottom = true
            performScroll(proxy: proxy, viewModel: viewModel, scrollWorkItem: scrollWorkItem)
        }
    }
}

// MARK: - Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// MARK: - Helper Types

struct ImageWrapper: Identifiable {
    let id = UUID()
    let path: String
}

#Preview {
    NavigationStack {
        ChatScreenView()
    }
}
