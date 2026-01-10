//
//  StorageService.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import Foundation
import SwiftData

@Model
final class MessageModel {
    @Attribute(.unique) var id: String
    var message: String
    var type: String
    var filePath: String?
    var fileSize: Int64
    var thumbnailPath: String?
    var sender: String
    var timestamp: Int64
    
    init(id: String, message: String, type: String, filePath: String? = nil, fileSize: Int64 = 0, thumbnailPath: String? = nil, sender: String, timestamp: Int64) {
        self.id = id
        self.message = message
        self.type = type
        self.filePath = filePath
        self.fileSize = fileSize
        self.thumbnailPath = thumbnailPath
        self.sender = sender
        self.timestamp = timestamp
    }
    
    func toMessage() -> Message {
        var fileInfo: FileInfo? = nil
        if type == "file", let path = filePath {
            let thumbnail = thumbnailPath.map { Thumbnail(path: $0) }
            fileInfo = FileInfo(path: path, fileSize: fileSize, thumbnail: thumbnail)
        }
        
        return Message(
            id: id,
            message: message,
            type: MessageType(rawValue: type) ?? .text,
            file: fileInfo,
            sender: Sender(rawValue: sender) ?? .user,
            timestamp: timestamp
        )
    }
    
    static func from(_ message: Message) -> MessageModel {
        return MessageModel(
            id: message.id,
            message: message.message,
            type: message.type.rawValue,
            filePath: message.file?.path,
            fileSize: message.file?.fileSize ?? 0,
            thumbnailPath: message.file?.thumbnail?.path,
            sender: message.sender.rawValue,
            timestamp: message.timestamp
        )
    }
}

class StorageService {
    static let shared = StorageService()
    
    let container: ModelContainer
    let context: ModelContext
    
    private init() {
        do {
            let schema = Schema([MessageModel.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            context = ModelContext(container)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
        
        seedDataIfNeeded()
    }
    
    private func seedDataIfNeeded() {
        let descriptor = FetchDescriptor<MessageModel>()
        
        do {
            let count = try context.fetchCount(descriptor)
            if count == 0 {
                // Insert seed data
                for message in SeedData.messages {
                    let model = MessageModel.from(message)
                    context.insert(model)
                }
                try context.save()
            }
        } catch {
            print("Error seeding data: \(error)")
        }
    }
    
    func fetchMessages(limit: Int, offset: Int) -> [Message] {
        var descriptor = FetchDescriptor<MessageModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        
        do {
            let models = try context.fetch(descriptor)
            return models.map { $0.toMessage() }
        } catch {
            print("Error fetching messages: \(error)")
            return []
        }
    }
    
    func getTotalMessageCount() -> Int {
        let descriptor = FetchDescriptor<MessageModel>()
        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("Error counting messages: \(error)")
            return 0
        }
    }
    
    func saveMessage(_ message: Message) {
        let model = MessageModel.from(message)
        context.insert(model)
        
        do {
            try context.save()
        } catch {
            print("Error saving message: \(error)")
        }
    }
    
    func deleteAllMessages() {
        do {
            try context.delete(model: MessageModel.self)
            try context.save()
        } catch {
            print("Error deleting messages: \(error)")
        }
    }
}
