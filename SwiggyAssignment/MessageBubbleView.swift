//
//  MessageBubbleView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                Text(message.message)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.sender == .user ? Color.blue : Color(.systemGray3))
                    .foregroundColor(message.sender == .user ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.formattedTime)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity, alignment: message.sender == .user ? .trailing : .leading)
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}
