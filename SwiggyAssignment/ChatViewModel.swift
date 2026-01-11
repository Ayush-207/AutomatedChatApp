//
//  ChatView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var displayedMessages: [Message] = []
    @Published var inputText: String = ""
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false
    @Published var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var showActionSheet = false
    @Published var selectedImageForFullScreen: String?
    @Published var isLoadingMore = false
    @Published var isAgentTyping: Bool = false
    var scrollToBottom: Bool = false
    
    private let sampleMessages: [String] = [
        "Great, will get that done for you!",
        "Thank you for choosing me as your consierge",
        "Can I help you out with anything else?",
        "Thanks a lot, have a nice day!"
    ]
    
    private let storage = StorageService.shared
    private let imageService = ImageService.shared
    private let messagesPerPage = 15
    private var currentOffset = 0
    private var totalMessageCount = 0
    
    init() {
        loadInitialMessages()
    }
    
    func loadInitialMessages() {
        totalMessageCount = storage.getTotalMessageCount()
        let startOffset = max(0, totalMessageCount - messagesPerPage)
        displayedMessages = storage.fetchMessages(limit: messagesPerPage, offset: startOffset)
        currentOffset = startOffset
        scrollToBottom = true
    }
    
    func loadMoreMessages() {
        guard !isLoadingMore && hasMoreMessages else { return }
        
        isLoadingMore = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let newOffset = max(0, self.currentOffset - self.messagesPerPage)
            let limit = self.currentOffset - newOffset
            
            let olderMessages = self.storage.fetchMessages(limit: limit, offset: newOffset)
            
            self.displayedMessages.insert(contentsOf: olderMessages, at: 0)
            self.currentOffset = newOffset
            self.isLoadingMore = false
        }
        scrollToBottom = false
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let newMessage = Message(
            id: UUID().uuidString,
            message: inputText,
            type: .text,
            file: nil,
            sender: .user,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        storage.saveMessage(newMessage)
        displayedMessages.append(newMessage)
        totalMessageCount += 1
        inputText = ""
        scrollToBottom = true
        simulateAgentMessage()
    }
    
    func sendImageMessage() {
        guard let image = selectedImage else { return }
        
        if let result = imageService.saveImage(image) {
            
            let thumbnailInfo = result.thumbnailURL.map { Thumbnail(path: $0) }
            
            let newMessage = Message(
                id: UUID().uuidString,
                message: inputText.isEmpty ? "" : inputText,
                type: .file,
                file: FileInfo(
                    path: result.originalURL,
                    fileSize: result.fileSize,
                    thumbnail: thumbnailInfo
                ),
                sender: .user,
                timestamp: Int64(Date().timeIntervalSince1970 * 1000)
            )
            
            storage.saveMessage(newMessage)
            displayedMessages.append(newMessage)
            totalMessageCount += 1
            inputText = ""
            selectedImage = nil
            scrollToBottom = true
        }
    }
    
    func openCamera() {
        imageSourceType = .camera
        showImagePicker = true
    }
    
    func openPhotoLibrary() {
        imageSourceType = .photoLibrary
        showImagePicker = true
    }
    
    private func simulateAgentMessage() {
        isAgentTyping = true
        scrollToBottom = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            self?.isAgentTyping = false
            self?.addRandomAgentMessage()
        }
    }
    
    private func addRandomAgentMessage() {
        guard let randomMessage = sampleMessages.randomElement() else { return }
        let newMessage = Message(
            id: UUID().uuidString,
            message: randomMessage,
            type: .text,
            file: nil,
            sender: .agent,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        storage.saveMessage(newMessage)
        displayedMessages.append(newMessage)
        totalMessageCount += 1
        scrollToBottom = true
    }
    
    var isMessageValid: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil
    }
    
    var hasMoreMessages: Bool {
        currentOffset > 0
    }
}
