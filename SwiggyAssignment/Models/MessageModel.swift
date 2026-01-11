//
//  MessageModel 2.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 12/01/26.
//
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
