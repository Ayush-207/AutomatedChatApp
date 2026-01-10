//
//  MessageType.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import Foundation

enum MessageType: String, Codable {
    case text
    case file
}

enum Sender: String, Codable {
    case user
    case agent
}

struct FileInfo: Codable {
    let path: String
    let fileSize: Int64
    let thumbnail: Thumbnail?
}

struct Thumbnail: Codable {
    let path: String
}

struct Message: Identifiable, Codable {
    let id: String
    let message: String
    let type: MessageType
    let file: FileInfo?
    let sender: Sender
    let timestamp: Int64
    
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000.0)
    }
    
    var formattedTime: String {
        date.smartFormatted()
    }
}
