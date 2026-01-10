import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false
    @Published var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var showActionSheet = false
    @Published var selectedImageForFullScreen: String?
    
    private let storage = StorageService.shared
    private let imageService = ImageService.shared
    
    init() {
        loadMessages()
    }
    
    func loadMessages() {
        messages = storage.loadMessages()
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        messages.append(Message(
            id: UUID().uuidString,
            message: inputText,
            type: .text,
            file: nil,
            sender: .user,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        ))
        storage.saveMessages(messages)
        inputText = ""
    }
    
    func sendImageMessage() {
        guard let image = selectedImage else { return }
        
        if let filename = imageService.saveImage(image) {
            let fileSize = imageService.getImageSize(filename: filename)
            
            let newMessage = Message(
                id: UUID().uuidString,
                message: inputText.isEmpty ? "" : inputText,
                type: .file,
                file: FileInfo(
                    path: filename,
                    fileSize: fileSize,
                    thumbnail: nil
                ),
                sender: .user,
                timestamp: Int64(Date().timeIntervalSince1970 * 1000)
            )
            
            messages.append(newMessage)
            storage.saveMessages(messages)
            inputText = ""
            selectedImage = nil
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
    
    var isMessageValid: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil
    }
}
