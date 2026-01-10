//
//  SeedData.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import Foundation

struct SeedData {
    static let messages: [Message] = [
        Message(
            id: "msg-001",
            message: "Hi! I need help booking a flight to Mumbai.",
            type: .text,
            file: nil,
            sender: .user,
            timestamp: 1703520000000
        ),
        Message(
            id: "msg-002",
            message: "Hello! I'd be happy to help you book a flight to Mumbai. When are you planning to travel?",
            type: .text,
            file: nil,
            sender: .agent,
            timestamp: 1703520030000
        ),
        Message(
            id: "msg-003",
            message: "Next Friday, December 29th.",
            type: .text,
            file: nil,
            sender: .user,
            timestamp: 1703520090000
        ),
        Message(
            id: "msg-004",
            message: "Great! And when would you like to return?",
            type: .text,
            file: nil,
            sender: .agent,
            timestamp: 1703520120000
        ),
        Message(
            id: "msg-005",
            message: "January 5th. Also, I prefer morning flights.",
            type: .text,
            file: nil,
            sender: .user,
            timestamp: 1703520180000
        ),
        Message(
            id: "msg-006",
            message: "Perfect! Let me search for morning flights from your location to Mumbai. Could you also share your departure city?",
            type: .text,
            file: nil,
            sender: .agent,
            timestamp: 1703520210000
        ),
        Message(
            id: "msg-007",
            message: "Bangalore. Here's a screenshot of my preferred airline.",
            type: .file,
            file: FileInfo(
                path: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400",
                fileSize: 245680,
                thumbnail: Thumbnail(path: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=100")
            ),
            sender: .user,
            timestamp: 1703520300000
        ),
        Message(
            id: "msg-008",
            message: "Thanks for sharing! I can see you prefer IndiGo. Let me find the best options for you.",
            type: .text,
            file: nil,
            sender: .agent,
            timestamp: 1703520330000
        ),
        Message(
            id: "msg-009",
            message: "I found 3 great options. Here's a comparison.",
            type: .file,
            file: FileInfo(
                path: "https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=400",
                fileSize: 189420,
                thumbnail: Thumbnail(path: "https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=100")
            ),
            sender: .agent,
            timestamp: 1703520420000
        ),
        Message(
            id: "msg-010",
            message: "The second option looks perfect! How do I proceed?",
            type: .text,
            file: nil,
            sender: .user,
            timestamp: 1703520480000
        )
    ]
}
