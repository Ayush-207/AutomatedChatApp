//
//  StorageService.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import Foundation

class StorageService {
    static let shared = StorageService()
    private let userDefaults = UserDefaults.standard
    private let messagesKey = "cached_messages"
    
    private init() {}
    
    func saveMessages(_ messages: [Message]) {
        if let encoded = try? JSONEncoder().encode(messages) {
            userDefaults.set(encoded, forKey: messagesKey)
        }
    }
    
    func loadMessages() -> [Message] {
        guard let data = userDefaults.data(forKey: messagesKey),
              let messages = try? JSONDecoder().decode([Message].self, from: data) else {
            return SeedData.messages
        }
        return messages
    }
    
    func clearMessages() {
        userDefaults.removeObject(forKey: messagesKey)
    }
}
