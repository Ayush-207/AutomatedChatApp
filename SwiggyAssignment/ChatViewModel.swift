//
//  ChatViewModel.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = SeedData.messages
    @Published var inputText: String = ""
        
    var isMessageValid: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func sendMessage() {
        guard isMessageValid else {
            return
        }
                
        messages.append(Message(
            id: UUID().uuidString,
            message: inputText,
            type: .text,
            sender: .user,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        ))
        inputText = ""
    }
}
