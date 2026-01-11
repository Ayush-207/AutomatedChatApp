//
//  ChatView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import SwiftUI
import Combine

final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        let willShow = NotificationCenter.default.publisher(
            for: UIResponder.keyboardWillShowNotification
        )
        let willHide = NotificationCenter.default.publisher(
            for: UIResponder.keyboardWillHideNotification
        )

        Publishers.Merge(willShow, willHide)
            .sink { notification in
                let frame = notification
                    .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                self.height = notification.name == UIResponder.keyboardWillHideNotification
                    ? 0
                    : frame?.height ?? 0
                
                print("LOGS:: keyboard height: \(self.height)")
            }
            .store(in: &cancellables)
    }
}

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

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @StateObject var keyboard = KeyboardObserver()
    
    var isAtBottom: Bool {
        let dif = bottomViewYOrigin - chatViewHeight
        return abs(dif) <= 40
    }
    
    var showFastScrollToBottom: Bool {
        return keyboard.height + chatViewHeight + 100.0 < bottomViewYOrigin
    }
    
    @State private var scrollWorkItem: DispatchWorkItem?
    
    @State var bottomViewYOrigin: CGFloat = 0
    @State var chatViewHeight: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 8) {
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
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .scrollView))
                                }
                            )
                    }
                    .padding(.vertical)
                }
                .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: { frame in
                    bottomViewYOrigin = frame.origin.y
                })
                .contentShape(Rectangle())
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                chatViewHeight = geometry.frame(in: .local).height
                            }
                            .onChange(of: geometry.frame(in: .local)) {
                                chatViewHeight = geometry.frame(in: .local).height
                            }
                    }
                )
                .onTapGesture {
                    hideKeyboard()
                }
                .onChange(of: viewModel.displayedMessages.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: keyboard.height) { oldValue, newValue in
                    print("LOGS:: keyboard height changed")
                    print("LOGS:: bottomViewYOrigin: \(bottomViewYOrigin)")
                    print("LOGS:: chatViewHeight: \(chatViewHeight)")
                    print("LOGS:: keyboard.height: \(keyboard.height)")
                    
                    if newValue > oldValue && (keyboard.height + chatViewHeight > bottomViewYOrigin) {
                        viewModel.scrollToBottom = true
                        scrollToBottom(proxy: proxy)
                    }
                }
                .onChange(of: viewModel.isAgentTyping)  { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onAppear {
                    scrollToBottom(proxy: proxy, shouldAnimate: false)
                }
                
                if showFastScrollToBottom {
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray)
                            .frame(width: 24, height: 24)
                        Image(systemName: "chevron.down.2")
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                    }
                    .padding(.bottom, 12)
                    .padding(.trailing, 12)
                    .onTapGesture {
                        viewModel.scrollToBottom = true
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, shouldAnimate: Bool = true) {
        print("LOGS:: \(#function)")
        guard scrollWorkItem == nil, viewModel.scrollToBottom else { return }
        print("LOGS:: scroll guard passed")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + (shouldAnimate ? 0.05 : 0), execute: task)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
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

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
