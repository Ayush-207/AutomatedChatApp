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
            sender: .user,
            timestamp: 1703520000000
        ),
        Message(
            id: "msg-002",
            message: "Hello! I'd be happy to help you book a flight to Mumbai. When are you planning to travel?",
            type: .text,
            sender: .agent,
            timestamp: 1703520030000
        ),
        Message(
            id: "msg-003",
            message: "Next Friday, December 29th.",
            type: .text,
            sender: .user,
            timestamp: 1703520090000
        ),
        Message(
            id: "msg-004",
            message: "Great! And when would you like to return?",
            type: .text,
            sender: .agent,
            timestamp: 1703520120000
        ),
        Message(
            id: "msg-005",
            message: "January 5th. Also, I prefer morning flights.",
            type: .text,
            sender: .user,
            timestamp: 1703520180000
        ),
        Message(
            id: "msg-006",
            message: "Perfect! Let me search for morning flights from your location to Mumbai. Could you also share your departure city?",
            type: .text,
            sender: .agent,
            timestamp: 1703520210000
        ),
        Message(
            id: "msg-007",
            message: "Bangalore. I prefer IndiGo airlines.",
            type: .text,
            sender: .user,
            timestamp: 1703520300000
        ),
        Message(
            id: "msg-008",
            message: "Thanks for sharing! I can see you prefer IndiGo. Let me find the best options for you.",
            type: .text,
            sender: .agent,
            timestamp: 1703520330000
        ),
        Message(
            id: "msg-009",
            message: "I found 3 great options for morning flights.",
            type: .text,
            sender: .agent,
            timestamp: 1703520420000
        ),
        Message(
            id: "msg-010",
            message: "The second option looks perfect! How do I proceed?",
            type: .text,
            sender: .user,
            timestamp: 1703520480000
        )
    ]
}
