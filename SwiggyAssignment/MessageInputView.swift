//
//  MessageInputView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import SwiftUI

struct MessageInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    var focusedState: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $viewModel.inputText, axis: .vertical)
                .focused(focusedState)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .lineLimit(1...5)
            
            Button(action: {
                viewModel.sendMessage()
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(viewModel.isMessageValid ? .blue : .gray)
            }
            .disabled(!viewModel.isMessageValid)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}
